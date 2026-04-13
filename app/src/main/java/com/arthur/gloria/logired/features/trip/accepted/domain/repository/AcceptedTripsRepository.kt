package com.arthur.gloria.logired.features.trip.accepted.domain.repository

import com.arthur.gloria.logired.core.network.model.Trip

interface AcceptedTripsRepository {
    suspend fun getAcceptedTrips(): Result<List<Trip>>
}