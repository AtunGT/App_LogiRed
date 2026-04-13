package com.arthur.gloria.logired.features.trip.available.domain.usecase

import com.arthur.gloria.logired.core.network.model.Trip
import com.arthur.gloria.logired.features.trip.available.domain.repository.AvailableTripsRepository
import javax.inject.Inject

class GetAvailableTripsUseCase @Inject constructor(
    private val repository: AvailableTripsRepository
) {
    suspend operator fun invoke(city: String): Result<List<Trip>> {
        return repository.getAvailableTrips(city)
    }
}