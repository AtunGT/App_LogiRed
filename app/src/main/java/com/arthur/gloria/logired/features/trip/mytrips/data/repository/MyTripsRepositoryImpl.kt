package com.arthur.gloria.logired.features.trip.mytrips.data.repository

import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.Trip
import com.arthur.gloria.logired.features.trip.mytrips.domain.repository.MyTripsRepository
import javax.inject.Inject

class MyTripsRepositoryImpl @Inject constructor(
    private val api: ApiService
) : MyTripsRepository {

    override suspend fun getMyTrips(): Result<List<Trip>> {
        return try {
            val response = api.getMyRequestedTrips()
            if (response.isSuccessful && response.body() != null) {
                Result.success(response.body()!!.rides ?: emptyList())
            } else {
                Result.failure(Exception("Error al obtener viajes: ${response.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }
}