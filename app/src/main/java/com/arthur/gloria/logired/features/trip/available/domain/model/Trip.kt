package com.arthur.gloria.logired.features.trip.available.domain.model

sealed class Trip {
    data class Success(val userId: String) : Trip()
    data class Error(val message: String) : Trip()
}