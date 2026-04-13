package com.arthur.gloria.logired.features.trip.dashboard.domain.usecase

import com.arthur.gloria.logired.core.network.model.Trip
import com.arthur.gloria.logired.features.trip.dashboard.domain.repository.DashboardRepository
import javax.inject.Inject

class GetDashboardStatsUseCase @Inject constructor(
    private val repository: DashboardRepository
) {
    suspend operator fun invoke(userType: Int): Result<List<Trip>> {
        return if (userType == 1) {
            repository.getClientTrips()
        } else {
            repository.getDriverTrips()
        }
    }
}
