package com.arthur.gloria.logired.features.trip.mytrips.presentation.ui

import com.arthur.gloria.logired.core.network.model.Trip

data class MyTripsUiState(
    val isLoading: Boolean          = false,
    val trips: List<Trip>           = emptyList(),
    val error: String?              = null,
    val successMessage: String?     = null,
    val showCancelDialog: Int?      = null,
    val proposalCounts: Map<Int, Int> = emptyMap()
)