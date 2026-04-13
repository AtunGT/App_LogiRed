package com.arthur.gloria.logired.features.trip.active.presentation.viewmodel

import android.annotation.SuppressLint
import android.content.Context
import android.location.Geocoder
import android.speech.tts.TextToSpeech
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.core.local.TokenManager
import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.UpdateStatusRequest
import com.arthur.gloria.logired.core.websocket.WebSocketManager
import com.arthur.gloria.logired.features.trip.active.presentation.ui.ActiveTripUiState
import com.arthur.gloria.logired.features.trip.active.presentation.ui.RouteStep
import com.arthur.gloria.logired.features.trip.active.presentation.ui.TripPhase
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.tasks.CancellationTokenSource
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.URL
import java.util.Locale
import javax.inject.Inject
import kotlin.math.*

@HiltViewModel
class ActiveTripViewModel @Inject constructor(
    private val apiService: ApiService,
    private val tokenManager: TokenManager,
    @ApplicationContext private val context: Context
) : ViewModel() {

    private val _uiState = MutableStateFlow(ActiveTripUiState())
    val uiState: StateFlow<ActiveTripUiState> = _uiState.asStateFlow()

    private val wsManager = WebSocketManager()
    private var locationJob: Job? = null
    private var reconnectJob: Job? = null
    private var statusPollingJob: Job? = null
    private val fusedLocationClient = LocationServices.getFusedLocationProviderClient(context)
    private val apiKey = "REMOVED"
    private var currentTripId = 0
    private var currentIsDriver = false
    private var tts: TextToSpeech? = null
    private var lastAnnouncedStep = -1

    init {
        tts = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale("es", "MX")
            }
        }
    }

    fun initialize(tripId: Int, isDriver: Boolean) {
        if (_uiState.value.tripId == tripId) return
        currentTripId = tripId
        currentIsDriver = isDriver
        _uiState.update { it.copy(tripId = tripId, isDriver = isDriver, isLoading = true) }
        viewModelScope.launch { loadTrip(tripId, isDriver) }
    }

    fun onLocationPermissionGranted() {
        val state = _uiState.value
        if (state.tripStatus == 3 && state.isDriver) {
            loadDriverRouteToOrigin()
            if (locationJob == null || locationJob?.isActive != true) {
                startPublishingLocation()
            }
        }
    }

    @SuppressLint("MissingPermission")
    private suspend fun getFreshLocation(): android.location.Location? {
        return try {
            val last = fusedLocationClient.lastLocation.await()
            if (last != null) return last
            val cts = CancellationTokenSource()
            fusedLocationClient.getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, cts.token).await()
        } catch (e: Exception) {
            Log.e("TripRoute", "getFreshLocation error: ${e.message}")
            null
        }
    }

    private fun calculateBearing(from: LatLng, to: LatLng): Float {
        val lat1 = Math.toRadians(from.latitude)
        val lat2 = Math.toRadians(to.latitude)
        val dLng = Math.toRadians(to.longitude - from.longitude)
        val y = sin(dLng) * cos(lat2)
        val x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng)
        val bearing = Math.toDegrees(atan2(y, x))
        return ((bearing + 360) % 360).toFloat()
    }

    private suspend fun loadTrip(tripId: Int, isDriver: Boolean) {
        try {
            val response = apiService.getRideById(tripId)
            if (response.isSuccessful) {
                val trip = response.body()?.ride ?: return
                val originLatLng = resolveLatLng(trip.origin_lat, trip.origin_lng, "${trip.origin}, ${trip.origin_city}")
                val destLatLng = resolveLatLng(trip.destination_lat, trip.destination_lng, trip.destination)

                val phase = when (trip.status) {
                    3 -> TripPhase.GOING_TO_ORIGIN
                    5 -> TripPhase.COMPLETED
                    else -> TripPhase.GOING_TO_ORIGIN
                }

                _uiState.update {
                    it.copy(
                        isLoading = false,
                        trip = trip,
                        tripStatus = trip.status,
                        phase = phase,
                        originLatLng = originLatLng,
                        destinationLatLng = destLatLng,
                        statusMessage = getStatusMessage(trip.status, phase)
                    )
                }

                when {
                    trip.status == 3 -> {
                        connectWebSocket(tripId, isDriver)
                        if (isDriver) loadDriverRouteToOrigin()
                    }
                    isDriver && trip.status == 1 -> {
                        if (originLatLng != null && destLatLng != null) {
                            val result = fetchRouteWithSteps(originLatLng, destLatLng)
                            _uiState.update {
                                it.copy(
                                    routePoints = result.first,
                                    steps = result.second,
                                    distanceRemaining = result.third.first,
                                    timeRemaining = result.third.second
                                )
                            }
                        }
                    }
                    !isDriver && (trip.status == 1 || trip.status == 2) -> {
                        startStatusPolling(tripId)
                    }
                }
            } else {
                _uiState.update { it.copy(isLoading = false, error = "Error al cargar el viaje") }
            }
        } catch (e: Exception) {
            _uiState.update { it.copy(isLoading = false, error = e.message) }
        }
    }

    private fun startStatusPolling(tripId: Int) {
        statusPollingJob?.cancel()
        statusPollingJob = viewModelScope.launch {
            while (true) {
                try {
                    val response = apiService.getRideById(tripId)
                    if (response.isSuccessful) {
                        val trip = response.body()?.ride ?: break
                        _uiState.update {
                            it.copy(
                                tripStatus = trip.status,
                                statusMessage = if (trip.status == 1) getStatusMessage(1, TripPhase.GOING_TO_ORIGIN) else it.statusMessage
                            )
                        }
                        when (trip.status) {
                            3 -> {
                                statusPollingJob?.cancel()
                                connectWebSocket(tripId, false)
                                _uiState.update {
                                    it.copy(
                                        phase = TripPhase.GOING_TO_ORIGIN,
                                        statusMessage = getStatusMessage(3, TripPhase.GOING_TO_ORIGIN)
                                    )
                                }
                                break
                            }
                            5 -> {
                                statusPollingJob?.cancel()
                                _uiState.update {
                                    it.copy(
                                        phase = TripPhase.COMPLETED,
                                        tripCompleted = true,
                                        statusMessage = getStatusMessage(5, TripPhase.COMPLETED)
                                    )
                                }
                                break
                            }
                            4 -> { statusPollingJob?.cancel(); break }
                        }
                    }
                } catch (e: Exception) { }
                delay(3000)
            }
        }
    }

    private fun connectWebSocket(tripId: Int, isDriver: Boolean) {
        viewModelScope.launch {
            val token = tokenManager.token.first() ?: return@launch
            val suffix = if (isDriver) "publish" else "subscribe"
            val url = "wss://logiredapi.redirectme.net/ws/rides/$tripId/$suffix?token=$token"

            wsManager.onOpen = {
                _uiState.update { it.copy(wsConnected = true) }
                if (isDriver) startPublishingLocation()
            }
            wsManager.onMessage = { text -> parseLocationMessage(text) }
            wsManager.onFailure = {
                _uiState.update { it.copy(wsConnected = false) }
                scheduleReconnect(tripId, isDriver)
            }
            wsManager.onClosed = { _uiState.update { it.copy(wsConnected = false) } }

            wsManager.connect(url)
        }
    }

    private fun scheduleReconnect(tripId: Int, isDriver: Boolean) {
        reconnectJob?.cancel()
        reconnectJob = viewModelScope.launch {
            delay(3000)
            if (_uiState.value.tripStatus == 3) connectWebSocket(tripId, isDriver)
        }
    }

    private fun startPublishingLocation() {
        locationJob?.cancel()
        locationJob = viewModelScope.launch {
            while (true) {
                try {
                    val loc = getFreshLocation()
                    loc?.let {
                        val phase = _uiState.value.phase.name
                        val msg = """{"lat":${it.latitude},"lng":${it.longitude},"timestamp":${System.currentTimeMillis() / 1000},"phase":"$phase"}"""
                        wsManager.send(msg)
                        val driverPos = LatLng(it.latitude, it.longitude)
                        val prev = _uiState.value.driverLatLng
                        val bearing = when {
                            it.hasBearing() && it.speed > 0.5f -> it.bearing
                            prev != null && haversineMeters(prev.latitude, prev.longitude, driverPos.latitude, driverPos.longitude) > 2.0 ->
                                calculateBearing(prev, driverPos)
                            else -> _uiState.value.driverBearing
                        }
                        _uiState.update { s -> s.copy(driverLatLng = driverPos, driverBearing = bearing) }
                        updateNavigationStep(driverPos)
                        if (_uiState.value.steps.isEmpty() &&
                            (_uiState.value.phase == TripPhase.GOING_TO_ORIGIN || _uiState.value.phase == TripPhase.IN_TRANSIT)
                        ) {
                            val dest = when (_uiState.value.phase) {
                                TripPhase.GOING_TO_ORIGIN -> _uiState.value.originLatLng
                                else -> _uiState.value.destinationLatLng
                            }
                            if (dest != null) {
                                val result = fetchRouteWithSteps(driverPos, dest)
                                _uiState.update { s ->
                                    s.copy(
                                        routePoints = result.first,
                                        steps = result.second,
                                        currentStepIndex = 0,
                                        distanceRemaining = result.third.first,
                                        timeRemaining = result.third.second
                                    )
                                }
                            }
                        }
                    }
                } catch (e: Exception) {
                    Log.e("TripRoute", "publishLocation error: ${e.message}")
                }
                delay(3000)
            }
        }
    }

    private fun parseLocationMessage(text: String) {
        try {
            val json = JSONObject(text)
            val lat = json.getDouble("lat")
            val lng = json.getDouble("lng")
            val phase = if (json.has("phase")) json.getString("phase") else null
            val newPhase = when (phase) {
                "GOING_TO_ORIGIN" -> TripPhase.GOING_TO_ORIGIN
                "AT_ORIGIN" -> TripPhase.AT_ORIGIN
                "IN_TRANSIT" -> TripPhase.IN_TRANSIT
                "COMPLETED" -> TripPhase.COMPLETED
                else -> null
            }
            _uiState.update { s ->
                val newPos = LatLng(lat, lng)
                val bearing = if (s.driverLatLng != null &&
                    haversineMeters(s.driverLatLng.latitude, s.driverLatLng.longitude, lat, lng) > 2.0
                ) calculateBearing(s.driverLatLng, newPos) else s.driverBearing
                s.copy(
                    driverLatLng = newPos,
                    driverBearing = bearing,
                    phase = newPhase ?: s.phase,
                    statusMessage = if (newPhase != null) getStatusMessage(3, newPhase) else s.statusMessage
                )
            }
        } catch (e: Exception) { }
    }

    private fun updateNavigationStep(driverPos: LatLng) {
        val steps = _uiState.value.steps
        if (steps.isEmpty()) return
        val currentIdx = _uiState.value.currentStepIndex
        if (currentIdx >= steps.size) return

        val distToEnd = haversineMeters(
            driverPos.latitude, driverPos.longitude,
            steps[currentIdx].endLocation.latitude,
            steps[currentIdx].endLocation.longitude
        )

        if (distToEnd < 30 && currentIdx + 1 < steps.size) {
            val nextIdx = currentIdx + 1
            _uiState.update { it.copy(currentStepIndex = nextIdx) }
            if (_uiState.value.isSpeakerOn && nextIdx != lastAnnouncedStep) {
                lastAnnouncedStep = nextIdx
                speak(steps[nextIdx].instruction)
            }
        }

        val dest = when (_uiState.value.phase) {
            TripPhase.GOING_TO_ORIGIN -> _uiState.value.originLatLng
            else -> _uiState.value.destinationLatLng
        }
        if (dest != null) {
            val remaining = haversineMeters(driverPos.latitude, driverPos.longitude, dest.latitude, dest.longitude)
            val distText = if (remaining >= 1000) "${"%.1f".format(remaining / 1000)} km" else "${remaining.toInt()} m"
            val timeMin = (remaining / 500).toInt().coerceAtLeast(1)
            _uiState.update { it.copy(distanceRemaining = distText, timeRemaining = "$timeMin min") }
        }
    }

    private fun speak(text: String) {
        val clean = text.replace(Regex("<[^>]*>"), "").replace(Regex("\\s+"), " ").trim()
        tts?.speak(clean, TextToSpeech.QUEUE_FLUSH, null, null)
    }

    fun toggleSpeaker() {
        val newVal = !_uiState.value.isSpeakerOn
        if (!newVal) tts?.stop()
        _uiState.update { it.copy(isSpeakerOn = newVal) }
    }

    fun centerOnDriver() {
        _uiState.update { it.copy(isFollowingDriver = true) }
    }

    private fun loadDriverRouteToOrigin() {
        viewModelScope.launch {
            try {
                val loc = getFreshLocation() ?: return@launch
                val driver = LatLng(loc.latitude, loc.longitude)
                val origin = _uiState.value.originLatLng ?: return@launch
                val result = fetchRouteWithSteps(driver, origin)
                lastAnnouncedStep = -1
                _uiState.update {
                    it.copy(
                        driverLatLng = driver,
                        routePoints = result.first,
                        steps = result.second,
                        currentStepIndex = 0,
                        distanceRemaining = result.third.first,
                        timeRemaining = result.third.second
                    )
                }
                if (_uiState.value.isSpeakerOn && result.second.isNotEmpty()) {
                    speak(result.second[0].instruction)
                }
            } catch (e: Exception) {
                Log.e("TripRoute", "loadDriverRouteToOrigin error: ${e.message}")
            }
        }
    }

    fun onStartTrip() {
        viewModelScope.launch {
            try {
                val response = apiService.updateRideStatus(_uiState.value.tripId, UpdateStatusRequest(3))
                if (response.isSuccessful) {
                    _uiState.update {
                        it.copy(
                            tripStatus = 3,
                            phase = TripPhase.GOING_TO_ORIGIN,
                            statusMessage = getStatusMessage(3, TripPhase.GOING_TO_ORIGIN)
                        )
                    }
                    connectWebSocket(currentTripId, currentIsDriver)
                    loadDriverRouteToOrigin()
                } else {
                    _uiState.update { it.copy(error = "Error al iniciar viaje") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(error = "Error al iniciar viaje: ${e.message}") }
            }
        }
    }

    fun onArrivedAtOrigin() {
        _uiState.update {
            it.copy(
                phase = TripPhase.AT_ORIGIN,
                statusMessage = getStatusMessage(3, TripPhase.AT_ORIGIN),
                steps = emptyList(),
                currentStepIndex = 0,
                distanceRemaining = "",
                timeRemaining = ""
            )
        }
    }

    fun onStartJourney() {
        viewModelScope.launch {
            _uiState.update {
                it.copy(
                    phase = TripPhase.IN_TRANSIT,
                    statusMessage = getStatusMessage(3, TripPhase.IN_TRANSIT)
                )
            }
            val origin = _uiState.value.driverLatLng ?: _uiState.value.originLatLng ?: return@launch
            val dest = _uiState.value.destinationLatLng ?: return@launch
            val result = fetchRouteWithSteps(origin, dest)
            lastAnnouncedStep = -1
            _uiState.update {
                it.copy(
                    routePoints = result.first,
                    steps = result.second,
                    currentStepIndex = 0,
                    distanceRemaining = result.third.first,
                    timeRemaining = result.third.second
                )
            }
            if (_uiState.value.isSpeakerOn && result.second.isNotEmpty()) {
                speak(result.second[0].instruction)
            }
        }
    }

    fun onArrivedAtDestination() {
        viewModelScope.launch {
            try {
                val response = apiService.updateRideStatus(_uiState.value.tripId, UpdateStatusRequest(5))
                if (response.isSuccessful) {
                    locationJob?.cancel()
                    wsManager.disconnect()
                    tts?.stop()
                    _uiState.update {
                        it.copy(
                            tripStatus = 5,
                            phase = TripPhase.COMPLETED,
                            tripCompleted = true,
                            statusMessage = getStatusMessage(5, TripPhase.COMPLETED)
                        )
                    }
                } else {
                    _uiState.update { it.copy(error = "Error al finalizar viaje") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(error = "Error al finalizar viaje: ${e.message}") }
            }
        }
    }

    private fun getStatusMessage(status: Int, phase: TripPhase): String = when {
        status == 1 -> "El conductor se está preparando"
        status == 3 && phase == TripPhase.GOING_TO_ORIGIN -> "El conductor está en camino a tu dirección"
        status == 3 && phase == TripPhase.AT_ORIGIN -> "El conductor llegó a tu dirección"
        status == 3 && phase == TripPhase.IN_TRANSIT -> "El viaje ha iniciado"
        status == 5 -> "Viaje completado ✅"
        else -> "Procesando..."
    }

    private suspend fun fetchRouteWithSteps(
        origin: LatLng,
        dest: LatLng
    ): Triple<List<LatLng>, List<RouteStep>, Pair<String, String>> =
        withContext(Dispatchers.IO) {
            try {
                val url = "https://maps.googleapis.com/maps/api/directions/json" +
                        "?origin=${origin.latitude},${origin.longitude}" +
                        "&destination=${dest.latitude},${dest.longitude}" +
                        "&mode=driving&language=es&key=$apiKey"
                val json = JSONObject(URL(url).readText())
                val status = json.optString("status")
                if (status != "OK") {
                    Log.e("TripRoute", "Directions status=$status msg=${json.optString("error_message")}")
                    return@withContext Triple(emptyList<LatLng>(), emptyList<RouteStep>(), Pair("", ""))
                }
                val routes = json.getJSONArray("routes")
                if (routes.length() == 0) return@withContext Triple(emptyList<LatLng>(), emptyList<RouteStep>(), Pair("", ""))

                val route = routes.getJSONObject(0)
                val leg = route.getJSONArray("legs").getJSONObject(0)
                val polyline = route.getJSONObject("overview_polyline").getString("points")
                val points = decodePolyline(polyline)
                val distText = leg.getJSONObject("distance").getString("text")
                val timeText = leg.getJSONObject("duration").getString("text")

                val stepsJson = leg.getJSONArray("steps")
                val steps = mutableListOf<RouteStep>()
                for (i in 0 until stepsJson.length()) {
                    val step = stepsJson.getJSONObject(i)
                    val instruction = step.getString("html_instructions")
                        .replace(Regex("<[^>]*>"), " ")
                        .replace(Regex("\\s+"), " ").trim()
                    val stepDist = step.getJSONObject("distance").getString("text")
                    val endLoc = step.getJSONObject("end_location")
                    val endLatLng = LatLng(endLoc.getDouble("lat"), endLoc.getDouble("lng"))
                    val maneuver = if (step.has("maneuver")) step.getString("maneuver") else ""
                    steps.add(RouteStep(instruction, stepDist, endLatLng, maneuver))
                }

                Triple(points, steps, Pair(distText, timeText))
            } catch (e: Exception) {
                Log.e("TripRoute", "fetchRoute error: ${e.message}")
                Triple(emptyList(), emptyList(), Pair("", ""))
            }
        }

    private fun decodePolyline(encoded: String): List<LatLng> {
        val poly = mutableListOf<LatLng>()
        var index = 0; var lat = 0; var lng = 0
        while (index < encoded.length) {
            var b: Int; var shift = 0; var result = 0
            do { b = encoded[index++].code - 63; result = result or ((b and 0x1f) shl shift); shift += 5 } while (b >= 0x20)
            val dLat = if (result and 1 != 0) (result shr 1).inv() else result shr 1; lat += dLat
            shift = 0; result = 0
            do { b = encoded[index++].code - 63; result = result or ((b and 0x1f) shl shift); shift += 5 } while (b >= 0x20)
            val dLng = if (result and 1 != 0) (result shr 1).inv() else result shr 1; lng += dLng
            poly.add(LatLng(lat / 1E5, lng / 1E5))
        }
        return poly
    }

    private fun haversineMeters(lat1: Double, lng1: Double, lat2: Double, lng2: Double): Double {
        val r = 6371000.0
        val dLat = Math.toRadians(lat2 - lat1)
        val dLng = Math.toRadians(lng2 - lng1)
        val a = sin(dLat / 2).pow(2) + cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) * sin(dLng / 2).pow(2)
        return r * 2 * atan2(sqrt(a), sqrt(1 - a))
    }

    private suspend fun resolveLatLng(lat: Double, lng: Double, address: String): LatLng? =
        if (lat != 0.0 && lng != 0.0) LatLng(lat, lng)
        else withContext(Dispatchers.IO) {
            try {
                @Suppress("DEPRECATION")
                Geocoder(context, Locale.getDefault()).getFromLocationName(address, 1)
                    ?.firstOrNull()?.let { LatLng(it.latitude, it.longitude) }
            } catch (e: Exception) { null }
        }

    override fun onCleared() {
        super.onCleared()
        locationJob?.cancel()
        reconnectJob?.cancel()
        statusPollingJob?.cancel()
        wsManager.disconnect()
        tts?.stop()
        tts?.shutdown()
    }
}