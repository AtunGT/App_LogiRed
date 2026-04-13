package com.arthur.gloria.logired.features.trip.mytrips.domain.repository

import com.arthur.gloria.logired.core.network.model.Trip

interface MyTripsRepository {
    suspend fun getMyTrips(): Result<List<Trip>>
}