package com.arthur.gloria.logired.features.trip.accepted.domain.usecase

import com.arthur.gloria.logired.features.trip.available.domain.repository.AvailableTripsRepository
import javax.inject.Inject

class AcceptTripUseCase @Inject constructor(
    private val repository: AvailableTripsRepository
) {

    suspend operator fun invoke(tripId: Int): Result<Unit> {
        return repository.acceptTrip(tripId)
    }
}