package com.arthur.gloria.logired.features.trip.request.domain.usecase

import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.TripRequest
import com.arthur.gloria.logired.features.trip.request.domain.model.TripRequestData
import org.json.JSONObject
import javax.inject.Inject

class RequestTripUseCase @Inject constructor(private val api: ApiService) {

    suspend operator fun invoke(data: TripRequestData): Result<Unit> {
        if (data.origin.isBlank())      return Result.failure(Exception("La dirección de origen es obligatoria"))
        if (data.originCity.isBlank())  return Result.failure(Exception("La ciudad de origen es obligatoria"))
        if (data.destination.isBlank()) return Result.failure(Exception("La dirección de destino es obligatoria"))
        if (data.date.isBlank())        return Result.failure(Exception("La fecha es obligatoria"))
        if (data.hour.isBlank())        return Result.failure(Exception("La hora es obligatoria"))

        return try {
            val request = TripRequest(
                origin_city    = data.originCity,
                origin         = data.origin,
                origin_lat     = data.originLat,
                origin_lng     = data.originLng,
                destination    = data.destination,
                destination_lat = data.destinationLat,
                destination_lng = data.destinationLng,
                distance_km    = data.distanceKm,
                date           = data.date,
                hour           = data.hour,
                approx_weight  = data.approxWeight,
                description    = data.description
            )
            val response = api.createTrip(request)
            if (response.isSuccessful) Result.success(Unit)
            else {
                val error = response.errorBody()?.string() ?: ""
                val msg = try { JSONObject(error).optString("error", "Error al crear viaje") } catch (e: Exception) { "Error al crear viaje" }
                Result.failure(Exception(msg))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }
}