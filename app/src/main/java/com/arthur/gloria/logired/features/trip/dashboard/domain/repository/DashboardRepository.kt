package com.arthur.gloria.logired.features.trip.dashboard.domain.repository

import com.arthur.gloria.logired.core.network.model.Trip

interface DashboardRepository {
    suspend fun getClientTrips(): Result<List<Trip>>
    suspend fun getDriverTrips(): Result<List<Trip>>
}
