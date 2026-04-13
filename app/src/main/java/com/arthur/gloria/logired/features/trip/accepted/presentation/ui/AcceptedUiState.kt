package com.arthur.gloria.logired.features.trip.accepted.presentation.ui

import com.arthur.gloria.logired.core.network.model.Trip

data class AcceptedTripsUiState(
    val trips: List<Trip> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)