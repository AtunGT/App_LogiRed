package com.arthur.gloria.logired.features.trip.request.domain.model

sealed class TripRequest {
    data class Success(val userId: String) : TripRequest()
    data class Error(val message: String) : TripRequest()
}