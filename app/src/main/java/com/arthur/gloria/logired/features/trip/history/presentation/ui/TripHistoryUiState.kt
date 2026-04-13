package com.arthur.gloria.logired.features.trip.history.presentation.ui

import com.arthur.gloria.logired.core.network.model.Trip

data class TripHistoryUiState(
    val isLoading: Boolean        = false,
    val trips: List<Trip>         = emptyList(),
    val filteredTrips: List<Trip> = emptyList(),
    val selectedStatus: Int?      = null,
    val error: String?            = null
)