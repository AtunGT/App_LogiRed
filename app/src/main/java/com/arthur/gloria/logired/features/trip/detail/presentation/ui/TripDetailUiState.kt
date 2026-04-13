package com.arthur.gloria.logired.features.trip.detail.presentation.ui

import com.arthur.gloria.logired.core.network.model.Trip

data class TripDetailUiState(
    val isLoading: Boolean = false,
    val trip: Trip?        = null,
    val error: String?     = null
)