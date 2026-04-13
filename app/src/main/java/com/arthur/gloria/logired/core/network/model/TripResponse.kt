package com.arthur.gloria.logired.core.network.model

data class TripResponse(
    val message: String,
    val trip: Trip? = null,
    val trips: List<Trip>? = null
)