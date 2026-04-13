package com.arthur.gloria.logired.features.trip.available.domain.repository

import com.arthur.gloria.logired.core.network.model.Trip

interface AvailableTripsRepository {
    suspend fun getAvailableTrips(city: String): Result<List<Trip>>

    suspend fun acceptTrip(tripId: Int): Result<Unit>
}