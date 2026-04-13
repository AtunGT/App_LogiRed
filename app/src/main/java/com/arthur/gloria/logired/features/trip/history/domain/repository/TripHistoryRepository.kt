package com.arthur.gloria.logired.features.trip.history.domain.repository

import com.arthur.gloria.logired.core.network.model.Trip

interface TripHistoryRepository {
    suspend fun getClientTrips(): Result<List<Trip>>
    suspend fun getDriverTrips(): Result<List<Trip>>
}
