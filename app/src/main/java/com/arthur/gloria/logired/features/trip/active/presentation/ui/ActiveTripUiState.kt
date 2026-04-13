package com.arthur.gloria.logired.features.trip.active.presentation.ui

import com.arthur.gloria.logired.core.network.model.Trip
import com.google.android.gms.maps.model.LatLng

enum class TripPhase {
    GOING_TO_ORIGIN,
    AT_ORIGIN,
    IN_TRANSIT,
    COMPLETED
}

data class RouteStep(
    val instruction: String,
    val distanceText: String,
    val endLocation: LatLng,
    val maneuver: String = ""
)

data class ActiveTripUiState(
    val tripId: Int = 0,
    val isDriver: Boolean = false,
    val trip: Trip? = null,
    val isLoading: Boolean = true,
    val error: String? = null,
    val wsConnected: Boolean = false,
    val originLatLng: LatLng? = null,
    val destinationLatLng: LatLng? = null,
    val driverLatLng: LatLng? = null,
    val driverBearing: Float = 0f,
    val routePoints: List<LatLng> = emptyList(),
    val tripStatus: Int = 1,
    val phase: TripPhase = TripPhase.GOING_TO_ORIGIN,
    val statusMessage: String = "",
    val tripCompleted: Boolean = false,
    val steps: List<RouteStep> = emptyList(),
    val currentStepIndex: Int = 0,
    val distanceRemaining: String = "",
    val timeRemaining: String = "",
    val isSpeakerOn: Boolean = true,
    val isFollowingDriver: Boolean = true,
    val driverLastUpdate: Long? = null
)