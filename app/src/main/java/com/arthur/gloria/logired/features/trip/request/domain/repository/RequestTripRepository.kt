package com.arthur.gloria.logired.features.trip.request.domain.repository

import com.arthur.gloria.logired.features.trip.request.domain.model.TripRequestData

interface RequestTripRepository {
    suspend fun requestTrip(tripData: TripRequestData): Result<Unit>
}