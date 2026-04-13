package com.arthur.gloria.logired.features.trip.mytrips.domain.usecase

import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.UpdateStatusRequest
import javax.inject.Inject

class CancelTripUseCase @Inject constructor(private val api: ApiService) {
    suspend operator fun invoke(tripId: Int): Result<Unit> {
        return try {
            val response = api.updateRideStatus(tripId, UpdateStatusRequest(status = 4))
            if (response.isSuccessful) Result.success(Unit)
            else Result.failure(Exception("Error al cancelar el viaje: ${response.code()}"))
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }
}