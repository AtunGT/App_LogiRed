package com.arthur.gloria.logired.features.trip.accepted.domain.usecase

import com.arthur.gloria.logired.core.network.model.Trip
import com.arthur.gloria.logired.features.trip.accepted.domain.repository.AcceptedTripsRepository
import javax.inject.Inject

class GetAcceptedTripsUseCase @Inject constructor(
    private val repository: AcceptedTripsRepository
) {
    suspend operator fun invoke(): Result<List<Trip>> {
        return repository.getAcceptedTrips()
    }
}