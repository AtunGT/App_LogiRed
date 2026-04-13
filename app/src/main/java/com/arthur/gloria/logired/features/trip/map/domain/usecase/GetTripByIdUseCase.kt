package com.arthur.gloria.logired.features.trip.map.domain.usecase

import com.arthur.gloria.logired.core.network.model.Trip
import com.arthur.gloria.logired.features.trip.map.domain.repository.TripMapRepository
import javax.inject.Inject

class GetTripByIdUseCase @Inject constructor(
    private val repository: TripMapRepository
) {
    suspend operator fun invoke(tripId: Int): Result<Trip> {

        val fromClient = repository.getClientTrips()
        val trip = fromClient.getOrNull()?.find { it.id == tripId }
        if (trip != null) return Result.success(trip)

        val fromDriver = repository.getDriverTrips()
        val tripFromDriver = fromDriver.getOrNull()?.find { it.id == tripId }
        if (tripFromDriver != null) return Result.success(tripFromDriver)

        return Result.failure(Exception("Mudanza #$tripId no encontrada"))
    }
}
