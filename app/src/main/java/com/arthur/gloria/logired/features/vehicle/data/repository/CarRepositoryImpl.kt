package com.arthur.gloria.logired.features.vehicle.data.repository

import android.content.Context
import android.net.Uri
import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.Car
import com.arthur.gloria.logired.features.vehicle.domain.model.CarData
import com.arthur.gloria.logired.features.vehicle.domain.repository.CarRepository
import dagger.hilt.android.qualifiers.ApplicationContext
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.File
import javax.inject.Inject

class CarRepositoryImpl @Inject constructor(
    private val api: ApiService,
    @ApplicationContext private val context: Context
) : CarRepository {

    override suspend fun getMyCars(): Result<List<Car>> {
        return try {
            val response = api.getMyCars()
            if (response.isSuccessful && response.body() != null) {
                Result.success(response.body()!!.cars ?: emptyList())
            } else {
                Result.failure(Exception("Error al obtener vehículos: ${response.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }

    override suspend fun getCarById(id: Int): Result<Car> {
        return try {
            val response = api.getCarById(id)
            if (response.isSuccessful && response.body()?.car != null) {
                Result.success(response.body()!!.car!!)
            } else {
                Result.failure(Exception("Vehículo no encontrado"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }

    override suspend fun createCar(carData: CarData): Result<Unit> {
        return try {
            val response = api.createCar(
                carRegistration = carData.carRegistration.toTextBody(),
                brand           = carData.brand.toTextBody(),
                model           = carData.model.toTextBody(),
                color           = carData.color.toTextBody(),
                maxCapacity     = carData.maxCapacity.toString().toTextBody(),
                frontViewImage  = carData.frontViewUri?.toMultipart(context, "frontview_image"),
                backViewImage   = carData.backViewUri?.toMultipart(context, "backview_image"),
                platesImage     = carData.platesUri?.toMultipart(context, "plates_image"),
                spacesImage     = carData.spacesUri?.toMultipart(context, "space_image")
            )
            if (response.isSuccessful) Result.success(Unit)
            else {
                val error = response.errorBody()?.string() ?: ""
                Result.failure(Exception(parseError(error)))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }

    override suspend fun updateCar(id: Int, carData: CarData): Result<Unit> {
        return try {
            val response = api.updateCar(
                id              = id,
                carRegistration = carData.carRegistration.toTextBody(),
                brand           = carData.brand.toTextBody(),
                model           = carData.model.toTextBody(),
                color           = carData.color.toTextBody(),
                maxCapacity     = carData.maxCapacity.toString().toTextBody(),
                frontViewImage  = carData.frontViewUri?.toMultipart(context, "frontview_image"),
                backViewImage   = carData.backViewUri?.toMultipart(context, "backview_image"),
                platesImage     = carData.platesUri?.toMultipart(context, "plates_image"),
                spacesImage     = carData.spacesUri?.toMultipart(context, "space_image")
            )
            if (response.isSuccessful) Result.success(Unit)
            else {
                val error = response.errorBody()?.string() ?: ""
                Result.failure(Exception(parseError(error)))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }

    override suspend fun deleteCar(id: Int): Result<Unit> {
        return try {
            val response = api.deleteCar(id)
            if (response.isSuccessful) Result.success(Unit)
            else Result.failure(Exception("Error al eliminar vehículo: ${response.code()}"))
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }

    private fun String.toTextBody(): RequestBody =
        this.toRequestBody("text/plain".toMediaTypeOrNull())

    private fun Uri.toMultipart(context: Context, fieldName: String): MultipartBody.Part {
        val stream = context.contentResolver.openInputStream(this)
        val file = File(context.cacheDir, "${fieldName}_${System.currentTimeMillis()}.jpg")
        file.outputStream().use { stream?.copyTo(it) }
        return MultipartBody.Part.createFormData(fieldName, file.name, file.asRequestBody("image/jpeg".toMediaTypeOrNull()))
    }

    private fun parseError(errorBody: String): String {
        return try {
            JSONObject(errorBody).optString("error", "Error al procesar vehículo")
        } catch (e: Exception) {
            "Error al procesar vehículo"
        }
    }
}