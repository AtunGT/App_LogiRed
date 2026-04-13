package com.arthur.gloria.logired.features.trip.request.presentation.viewmodel

import android.annotation.SuppressLint
import android.content.Context
import android.location.Geocoder
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.features.trip.request.domain.model.TripRequestData
import com.arthur.gloria.logired.features.trip.request.domain.usecase.RequestTripUseCase
import com.arthur.gloria.logired.features.trip.request.presentation.ui.RequestTripUiState
import com.google.android.gms.location.LocationServices
import com.google.android.libraries.places.api.Places
import com.google.android.libraries.places.api.model.AutocompletePrediction
import com.google.android.libraries.places.api.model.Place
import com.google.android.libraries.places.api.net.FetchPlaceRequest
import com.google.android.libraries.places.api.net.FindAutocompletePredictionsRequest
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import java.util.Locale
import javax.inject.Inject
import kotlin.math.*

@HiltViewModel
class RequestTripViewModel @Inject constructor(
    private val requestTripUseCase: RequestTripUseCase,
    @ApplicationContext private val context: Context
) : ViewModel() {

    private val _uiState = MutableStateFlow(RequestTripUiState())
    val uiState: StateFlow<RequestTripUiState> = _uiState.asStateFlow()

    private val placesClient by lazy { Places.createClient(context) }
    private val fusedLocationClient by lazy { LocationServices.getFusedLocationProviderClient(context) }

    fun onOriginChange(v: String) {
        _uiState.update { it.copy(origin = v, showOriginSuggestions = v.length >= 3, originLat = 0.0, originLng = 0.0) }
        if (v.length >= 3) fetchSuggestions(v, isOrigin = true)
        else _uiState.update { it.copy(originSuggestions = emptyList()) }
    }

    fun onDestinationChange(v: String) {
        _uiState.update { it.copy(destination = v, showDestinationSuggestions = v.length >= 3, destinationLat = 0.0, destinationLng = 0.0) }
        if (v.length >= 3) fetchSuggestions(v, isOrigin = false)
        else _uiState.update { it.copy(destinationSuggestions = emptyList()) }
    }

    fun onOriginCityChange(v: String)   = _uiState.update { it.copy(originCity = v) }
    fun onDateChange(v: String)         = _uiState.update { it.copy(date = v) }
    fun onHourChange(v: String)         = _uiState.update { it.copy(hour = v) }
    fun onApproxWeightChange(v: String) = _uiState.update { it.copy(approxWeight = v) }
    fun onDescriptionChange(v: String)  = _uiState.update { it.copy(description = v) }

    fun onOriginSuggestionSelected(prediction: AutocompletePrediction) {
        _uiState.update {
            it.copy(
                origin                = prediction.getFullText(null).toString(),
                showOriginSuggestions = false,
                originSuggestions     = emptyList()
            )
        }
        fetchPlaceLatLng(prediction.placeId, isOrigin = true)
    }

    fun onDestinationSuggestionSelected(prediction: AutocompletePrediction) {
        _uiState.update {
            it.copy(
                destination                = prediction.getFullText(null).toString(),
                showDestinationSuggestions = false,
                destinationSuggestions     = emptyList()
            )
        }
        fetchPlaceLatLng(prediction.placeId, isOrigin = false)
    }

    fun dismissOriginSuggestions()      = _uiState.update { it.copy(showOriginSuggestions = false) }
    fun dismissDestinationSuggestions() = _uiState.update { it.copy(showDestinationSuggestions = false) }

    private fun fetchPlaceLatLng(placeId: String, isOrigin: Boolean) {
        viewModelScope.launch {
            try {
                val request = FetchPlaceRequest.newInstance(
                    placeId,
                    listOf(Place.Field.LAT_LNG, Place.Field.ADDRESS_COMPONENTS)
                )
                val response = placesClient.fetchPlace(request).await()
                val latLng = response.place.latLng ?: return@launch

                if (isOrigin) {
                    val city = extractCityFromPlace(response.place)
                    _uiState.update {
                        it.copy(
                            originLat  = latLng.latitude,
                            originLng  = latLng.longitude,
                            originCity = if (city.isNotBlank()) city else it.originCity
                        )
                    }
                } else {
                    _uiState.update {
                        it.copy(
                            destinationLat = latLng.latitude,
                            destinationLng = latLng.longitude
                        )
                    }
                }
                recalculateDistance()
            } catch (e: Exception) { }
        }
    }

    private fun extractCityFromPlace(place: com.google.android.libraries.places.api.model.Place): String {
        val components = place.addressComponents?.asList() ?: return ""
        val locality = components.firstOrNull { it.types.contains("locality") }?.name
        val sublocality = components.firstOrNull { it.types.contains("sublocality") }?.name
        val adminArea = components.firstOrNull { it.types.contains("administrative_area_level_1") }?.name
        val city = locality ?: sublocality ?: ""
        return if (city.isNotBlank() && adminArea != null) "$city, $adminArea" else city.ifBlank { adminArea ?: "" }
    }

    private fun recalculateDistance() {
        val s = _uiState.value
        if (s.originLat != 0.0 && s.destinationLat != 0.0) {
            val dist = haversineKm(s.originLat, s.originLng, s.destinationLat, s.destinationLng)
            _uiState.update { it.copy(distanceKm = dist) }
        }
    }

    private fun haversineKm(lat1: Double, lng1: Double, lat2: Double, lng2: Double): Double {
        val r = 6371.0
        val dLat = Math.toRadians(lat2 - lat1)
        val dLng = Math.toRadians(lng2 - lng1)
        val a = sin(dLat / 2).pow(2) + cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) * sin(dLng / 2).pow(2)
        return r * 2 * atan2(sqrt(a), sqrt(1 - a))
    }

    @SuppressLint("MissingPermission")
    fun fetchCurrentLocation() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLocating = true) }
            try {
                val location = fusedLocationClient.lastLocation.await()
                if (location != null) {
                    @Suppress("DEPRECATION")
                    val results = Geocoder(context, Locale.getDefault())
                        .getFromLocation(location.latitude, location.longitude, 1)
                    val address = results?.firstOrNull()
                    if (address != null) {
                        val street = buildString {
                            address.thoroughfare?.let { append(it) }
                            address.subThoroughfare?.let { append(" $it") }
                        }.ifBlank { address.getAddressLine(0) ?: "" }
                        val state    = address.adminArea ?: ""
                        val locality = address.locality ?: address.subAdminArea ?: ""
                        val city     = if (state.isNotBlank() && locality.isNotBlank()) "$locality, $state"
                        else locality.ifBlank { state }
                        _uiState.update {
                            it.copy(
                                origin     = street,
                                originCity = city,
                                originLat  = location.latitude,
                                originLng  = location.longitude,
                                isLocating = false
                            )
                        }
                        recalculateDistance()
                    } else {
                        _uiState.update { it.copy(isLocating = false) }
                    }
                } else {
                    _uiState.update { it.copy(isLocating = false) }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLocating = false) }
            }
        }
    }

    private fun fetchSuggestions(query: String, isOrigin: Boolean) {
        viewModelScope.launch {
            try {
                val request = FindAutocompletePredictionsRequest.builder()
                    .setQuery(query)
                    .build()
                val response = placesClient.findAutocompletePredictions(request).await()
                if (isOrigin) {
                    _uiState.update { it.copy(originSuggestions = response.autocompletePredictions) }
                } else {
                    _uiState.update { it.copy(destinationSuggestions = response.autocompletePredictions) }
                }
            } catch (e: Exception) {
            android.util.Log.e("PlacesError", "Error: ${e.message}", e)
        }
        }
    }

    fun onRequestClick() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            val s = _uiState.value
            val weight = s.approxWeight.toIntOrNull()
            if (weight == null || weight <= 0) {
                _uiState.update { it.copy(isLoading = false, error = "Peso debe ser un número válido mayor a 0") }
                return@launch
            }
            val tripData = TripRequestData(
                origin       = s.origin,
                originCity   = s.originCity,
                originLat    = s.originLat,
                originLng    = s.originLng,
                destination  = s.destination,
                destinationLat = s.destinationLat,
                destinationLng = s.destinationLng,
                distanceKm   = s.distanceKm,
                date         = s.date,
                hour         = s.hour,
                approxWeight = weight,
                description  = s.description
            )
            requestTripUseCase(tripData)
                .onSuccess { _uiState.update { it.copy(isLoading = false, requestSuccess = true) } }
                .onFailure { e -> _uiState.update { it.copy(isLoading = false, error = e.message) } }
        }
    }

    fun onNavigationHandled() = _uiState.update { it.copy(requestSuccess = false) }
}