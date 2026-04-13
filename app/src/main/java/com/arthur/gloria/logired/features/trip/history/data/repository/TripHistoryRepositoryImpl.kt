package com.arthur.gloria.logired.features.trip.history.data.repository

import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.Trip
import com.arthur.gloria.logired.features.trip.history.domain.repository.TripHistoryRepository
import javax.inject.Inject

class TripHistoryRepositoryImpl @Inject constructor(
    private val api: ApiService
) : TripHistoryRepository {

    override suspend fun getClientTrips(): Result<List<Trip>> {
        return try {
            val response = api.getMyRequestedTrips()
            if (response.isSuccessful && response.body() != null) {
                Result.success(response.body()!!.rides ?: emptyList())
            } else {
                Result.failure(Exception("Error al obtener historial: ${response.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }

    override suspend fun getDriverTrips(): Result<List<Trip>> {
        return try {
            val response = api.getMyAcceptedTrips()
            if (response.isSuccessful && response.body() != null) {
                Result.success(response.body()!!.rides ?: emptyList())
            } else {
                Result.failure(Exception("Error al obtener historial: ${response.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }
}