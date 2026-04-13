package com.arthur.gloria.logired.features.trip.accepted.data.repository

import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.Trip
import com.arthur.gloria.logired.features.trip.accepted.domain.repository.AcceptedTripsRepository
import javax.inject.Inject

class AcceptedTripsRepositoryImpl @Inject constructor(
    private val api: ApiService
) : AcceptedTripsRepository {

    override suspend fun getAcceptedTrips(): Result<List<Trip>> {
        return try {
            val response = api.getMyAcceptedTrips()
            if (response.isSuccessful && response.body() != null) {
                Result.success(response.body()!!.rides ?: emptyList())
            } else {
                Result.failure(Exception("Error al obtener viajes aceptados: ${response.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }
}