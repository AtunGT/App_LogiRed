package com.arthur.gloria.logired.features.trip.dashboard.presentation.ui

data class DashboardUiState(
    val isLoading: Boolean  = false,
    val error: String?      = null,
    val totalTrips: Int     = 0,
    val pendingTrips: Int   = 0,
    val acceptedTrips: Int  = 0,
    val completedTrips: Int = 0,
    val cancelledTrips: Int = 0,
    val totalWeightKg: Int  = 0,
    val topCity: String     = "-",
    val lastTripDate: String = "-"
)