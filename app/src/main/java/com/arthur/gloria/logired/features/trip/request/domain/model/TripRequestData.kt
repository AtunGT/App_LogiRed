package com.arthur.gloria.logired.features.trip.request.domain.model

data class TripRequestData(
    val origin: String,
    val originCity: String,
    val originLat: Double      = 0.0,
    val originLng: Double      = 0.0,
    val destination: String,
    val destinationLat: Double = 0.0,
    val destinationLng: Double = 0.0,
    val distanceKm: Double     = 0.0,
    val date: String,
    val hour: String,
    val approxWeight: Int,
    val description: String
)