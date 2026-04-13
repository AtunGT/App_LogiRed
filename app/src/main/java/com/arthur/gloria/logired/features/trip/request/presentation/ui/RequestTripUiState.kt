package com.arthur.gloria.logired.features.trip.request.presentation.ui

import com.google.android.libraries.places.api.model.AutocompletePrediction

data class RequestTripUiState(
    val origin: String       = "",
    val originCity: String   = "",
    val destination: String  = "",
    val date: String         = "",
    val hour: String         = "",
    val approxWeight: String = "",
    val description: String  = "",
    val originLat: Double    = 0.0,
    val originLng: Double    = 0.0,
    val destinationLat: Double = 0.0,
    val destinationLng: Double = 0.0,
    val distanceKm: Double   = 0.0,
    val isLoading: Boolean   = false,
    val isLocating: Boolean  = false,
    val error: String?       = null,
    val requestSuccess: Boolean = false,
    val originSuggestions: List<AutocompletePrediction>      = emptyList(),
    val destinationSuggestions: List<AutocompletePrediction> = emptyList(),
    val showOriginSuggestions: Boolean      = false,
    val showDestinationSuggestions: Boolean = false
)