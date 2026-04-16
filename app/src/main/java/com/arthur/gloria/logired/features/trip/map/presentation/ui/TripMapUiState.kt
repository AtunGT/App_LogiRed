package com.arthur.gloria.logired.features.trip.map.presentation.viewmodel

import com.arthur.gloria.logired.core.network.model.Trip
import com.google.android.gms.maps.model.LatLng

data class TripMapUiState(
    val isLoading: Boolean         = true,
    val trip: Trip?                = null,
    val originLatLng: LatLng?      = null,
    val destinationLatLng: LatLng? = null,
    val routePoints: List<LatLng>  = emptyList(),
    val error: String?             = null
)