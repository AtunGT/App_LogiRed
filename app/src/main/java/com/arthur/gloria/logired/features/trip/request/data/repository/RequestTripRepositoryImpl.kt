package com.arthur.gloria.logired.features.trip.request.data.repository

import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.TripRequest
import com.arthur.gloria.logired.features.trip.request.domain.model.TripRequestData
import com.arthur.gloria.logired.features.trip.request.domain.repository.RequestTripRepository
import javax.inject.Inject

class RequestTripRepositoryImpl @Inject constructor(
    private val api: ApiService
) : RequestTripRepository {

    override suspend fun requestTrip(tripData: TripRequestData): Result<Unit> {
        return try {
            val request = TripRequest(
                origin_city     = tripData.originCity,
                origin          = tripData.origin,
                origin_lat      = tripData.originLat,
                origin_lng      = tripData.originLng,
                destination     = tripData.destination,
                destination_lat = tripData.destinationLat,
                destination_lng = tripData.destinationLng,
                distance_km     = tripData.distanceKm,
                date            = tripData.date,
                hour            = tripData.hour,
                approx_weight   = tripData.approxWeight,
                description     = tripData.description
            )
            val response = api.createTrip(request)
            if (response.isSuccessful) Result.success(Unit)
            else Result.failure(Exception("Error al solicitar viaje: ${response.code()} - ${response.errorBody()?.string()}"))
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }
}