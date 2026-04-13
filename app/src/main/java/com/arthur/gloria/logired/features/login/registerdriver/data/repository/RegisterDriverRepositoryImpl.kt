package com.arthur.gloria.logired.features.login.registerdriver.data.repository

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.features.login.registerdriver.domain.model.DriverData
import com.arthur.gloria.logired.features.login.registerdriver.domain.repository.RegisterDriverRepository
import dagger.hilt.android.qualifiers.ApplicationContext
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import javax.inject.Inject

class RegisterDriverRepositoryImpl @Inject constructor(
    private val api: ApiService,
    @ApplicationContext private val context: Context
) : RegisterDriverRepository {

    override suspend fun register(driver: DriverData): Result<Unit> {
        return try {
            val imagePart = driver.imageUri?.let { uri ->
                val inputStream = context.contentResolver.openInputStream(uri)
                val bitmap = BitmapFactory.decodeStream(inputStream)
                val file = File(context.cacheDir, "upload_${System.currentTimeMillis()}.jpg")
                FileOutputStream(file).use { out ->
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 80, out)
                }
                MultipartBody.Part.createFormData("image", file.name, file.asRequestBody("image/jpeg".toMediaTypeOrNull()))
            }

            val response = api.createUser(
                name        = driver.name.toTextRequestBody(),
                lastname    = driver.lastname.toTextRequestBody(),
                email       = driver.email.toTextRequestBody(),
                numberphone = driver.numberPhone.toTextRequestBody(),
                birthdate   = driver.birthdate.toTextRequestBody(),
                password    = driver.password.toTextRequestBody(),
                userType    = "2".toTextRequestBody(),
                image       = imagePart,
                citywork    = driver.citywork.toTextRequestBody()
            )

            if (response.isSuccessful) {
                Result.success(Unit)
            } else {
                val errorBody = response.errorBody()?.string() ?: ""
                Result.failure(Exception(parseBackendError(errorBody)))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión: ${e.message}"))
        }
    }

    private fun parseBackendError(errorBody: String): String {
        if (!errorBody.trimStart().startsWith("{")) return "Error al registrar"
        return try {
            val msg = JSONObject(errorBody).optString("error", "")
            when {
                msg.contains("email", ignoreCase = true) && msg.contains("Duplicate") ->
                    "Este correo electrónico ya está registrado"
                msg.contains("numberphone", ignoreCase = true) && msg.contains("Duplicate") ->
                    "Este número de teléfono ya está registrado"
                msg.isNotBlank() -> msg
                else -> "Error al registrar"
            }
        } catch (e: Exception) {
            "Error al registrar"
        }
    }

    private fun String.toTextRequestBody(): RequestBody =
        this.toRequestBody("text/plain".toMediaTypeOrNull())
}