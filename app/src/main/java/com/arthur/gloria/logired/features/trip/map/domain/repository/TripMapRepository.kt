package com.arthur.gloria.logired.features.trip.map.domain.repository

import com.arthur.gloria.logired.core.network.model.Trip

interface TripMapRepository {
    suspend fun getClientTrips(): Result<List<Trip>>
    suspend fun getDriverTrips(): Result<List<Trip>>
}