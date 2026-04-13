package com.arthur.gloria.logired.features.trip.available.data.repository

import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.Trip
import com.arthur.gloria.logired.features.trip.available.domain.repository.AvailableTripsRepository
import javax.inject.Inject

class AvailableTripsRepositoryImpl @Inject constructor(
    private val api: ApiService
) : AvailableTripsRepository {

    override suspend fun getAvailableTrips(city: String): Result<List<Trip>> {
        return try {
            val response = api.getTripsByCity(city)
            if (response.isSuccessful && response.body() != null) {
                Result.success(response.body()!!.rides ?: emptyList())
            } else {
                Result.failure(Exception("Error al obtener viajes disponibles: ${response.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }

    override suspend fun acceptTrip(tripId: Int): Result<Unit> {
        return try {
            val response = api.acceptTrip(tripId)
            if (response.isSuccessful) {
                Result.success(Unit)
            } else {
                Result.failure(Exception("Error al aceptar viaje: ${response.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }
}