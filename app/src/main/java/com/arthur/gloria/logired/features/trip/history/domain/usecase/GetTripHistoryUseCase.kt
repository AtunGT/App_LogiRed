package com.arthur.gloria.logired.features.trip.history.domain.usecase

import com.arthur.gloria.logired.core.network.model.Trip
import com.arthur.gloria.logired.features.trip.history.domain.repository.TripHistoryRepository
import javax.inject.Inject

class GetTripHistoryUseCase @Inject constructor(
    private val repository: TripHistoryRepository
) {
    suspend operator fun invoke(userType: Int): Result<List<Trip>> {
        return if (userType == 1) {
            repository.getClientTrips()
        } else {
            repository.getDriverTrips()
        }
    }
}
