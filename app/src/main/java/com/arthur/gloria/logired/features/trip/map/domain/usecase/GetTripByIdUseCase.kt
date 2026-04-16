package com.arthur.gloria.logired.features.trip.map.domain.usecase

import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.Trip
import javax.inject.Inject

class GetTripByIdUseCase @Inject constructor(
    private val apiService: ApiService
) {
    suspend operator fun invoke(tripId: Int): Result<Trip> {
        return try {
            val response = apiService.getRideById(tripId)
            if (response.isSuccessful) {
                val trip = response.body()?.ride
                if (trip != null) Result.success(trip)
                else Result.failure(Exception("Mudanza #$tripId no encontrada"))
            } else {
                Result.failure(Exception("Error ${response.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }
}