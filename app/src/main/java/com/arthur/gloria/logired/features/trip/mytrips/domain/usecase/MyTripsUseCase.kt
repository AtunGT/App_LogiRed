package com.arthur.gloria.logired.features.trip.mytrips.domain.usecase

import com.arthur.gloria.logired.core.network.model.Trip
import com.arthur.gloria.logired.features.trip.mytrips.domain.repository.MyTripsRepository
import javax.inject.Inject

class GetMyTripsUseCase @Inject constructor(
    private val repository: MyTripsRepository
) {
    suspend operator fun invoke(): Result<List<Trip>> {
        return repository.getMyTrips()
    }
}