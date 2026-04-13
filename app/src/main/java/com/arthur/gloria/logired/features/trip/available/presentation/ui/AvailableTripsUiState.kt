package com.arthur.gloria.logired.features.trip.available.presentation.ui

import com.arthur.gloria.logired.core.network.model.Trip

data class AvailableTripsUiState(
    val trips: List<Trip> = emptyList(),
    val city: String = "",
    val isLoading: Boolean = false,
    val error: String? = null
)