package com.arthur.gloria.logired.features.trip.map.presentation.viewmodel

import android.content.Context
import android.location.Geocoder
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.core.network.model.Trip
import com.arthur.gloria.logired.features.trip.map.domain.usecase.GetTripByIdUseCase
import com.google.android.gms.maps.model.LatLng
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.URL
import java.util.Locale
import javax.inject.Inject

data class TripMapUiState(
    val isLoading: Boolean         = true,
    val trip: Trip?                = null,
    val originLatLng: LatLng?      = null,
    val destinationLatLng: LatLng? = null,
    val routePoints: List<LatLng>  = emptyList(),
    val driverLatLng: LatLng?      = null,
    val driverLastUpdate: Long?    = null,
    val isLiveConnected: Boolean   = false,
    val error: String?             = null
)

@HiltViewModel
class TripMapViewModel @Inject constructor(
    private val getTripByIdUseCase: GetTripByIdUseCase,
    @ApplicationContext private val context: Context
) : ViewModel() {

    private val _uiState = MutableStateFlow(TripMapUiState())
    val uiState: StateFlow<TripMapUiState> = _uiState.asStateFlow()

    private val apiKey = "REMOVED"

    fun loadTrip(tripId: Int) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            getTripByIdUseCase(tripId)
                .onSuccess { trip ->
                    val originLatLng = if (trip.origin_lat != 0.0 && trip.origin_lng != 0.0)
                        LatLng(trip.origin_lat, trip.origin_lng)
                    else geocodeAddress("${trip.origin}, ${trip.origin_city}")

                    val destLatLng = if (trip.destination_lat != 0.0 && trip.destination_lng != 0.0)
                        LatLng(trip.destination_lat, trip.destination_lng)
                    else geocodeAddress(trip.destination)

                    val route = if (originLatLng != null && destLatLng != null)
                        fetchRoute(originLatLng, destLatLng)
                    else emptyList()

                    _uiState.update {
                        it.copy(
                            isLoading         = false,
                            trip              = trip,
                            originLatLng      = originLatLng,
                            destinationLatLng = destLatLng,
                            routePoints       = route
                        )
                    }
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isLoading = false, error = e.message) }
                }
        }
    }

    private suspend fun fetchRoute(origin: LatLng, dest: LatLng): List<LatLng> =
        withContext(Dispatchers.IO) {
            try {
                val url = "https://maps.googleapis.com/maps/api/directions/json" +
                        "?origin=${origin.latitude},${origin.longitude}" +
                        "&destination=${dest.latitude},${dest.longitude}" +
                        "&mode=driving" +
                        "&key=$apiKey"
                val response = URL(url).readText()
                val json = JSONObject(response)
                val routes = json.getJSONArray("routes")
                if (routes.length() == 0) return@withContext emptyList()
                val polyline = routes.getJSONObject(0)
                    .getJSONObject("overview_polyline")
                    .getString("points")
                decodePolyline(polyline)
            } catch (e: Exception) {
                emptyList()
            }
        }

    private fun decodePolyline(encoded: String): List<LatLng> {
        val poly = mutableListOf<LatLng>()
        var index = 0
        var lat = 0
        var lng = 0
        while (index < encoded.length) {
            var b: Int
            var shift = 0
            var result = 0
            do {
                b = encoded[index++].code - 63
                result = result or ((b and 0x1f) shl shift)
                shift += 5
            } while (b >= 0x20)
            val dLat = if (result and 1 != 0) (result shr 1).inv() else result shr 1
            lat += dLat
            shift = 0
            result = 0
            do {
                b = encoded[index++].code - 63
                result = result or ((b and 0x1f) shl shift)
                shift += 5
            } while (b >= 0x20)
            val dLng = if (result and 1 != 0) (result shr 1).inv() else result shr 1
            lng += dLng
            poly.add(LatLng(lat / 1E5, lng / 1E5))
        }
        return poly
    }

    private suspend fun geocodeAddress(address: String): LatLng? =
        withContext(Dispatchers.IO) {
            try {
                @Suppress("DEPRECATION")
                val results = Geocoder(context, Locale.getDefault()).getFromLocationName(address, 1)
                results?.firstOrNull()?.let { LatLng(it.latitude, it.longitude) }
            } catch (e: Exception) {
                null
            }
        }
}