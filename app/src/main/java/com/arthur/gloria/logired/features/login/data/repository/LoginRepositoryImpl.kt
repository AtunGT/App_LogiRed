package com.arthur.gloria.logired.features.login.data.repository

import android.util.Base64
import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.LoginRequest
import com.arthur.gloria.logired.core.network.model.ResetPasswordRequest
import com.arthur.gloria.logired.features.login.domain.model.LoginResult
import com.arthur.gloria.logired.features.login.domain.repository.LoginRepository
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.tasks.await
import org.json.JSONObject
import javax.inject.Inject

class LoginRepositoryImpl @Inject constructor(
    private val api: ApiService
) : LoginRepository {

    private val auth = FirebaseAuth.getInstance()

    override suspend fun login(email: String, password: String): LoginResult {
        return try {
            syncPasswordIfNeeded(email, password)

            val response = api.login(LoginRequest(email, password))

            if (response.isSuccessful) {
                val authHeader = response.headers()["Authorization"]

                if (!authHeader.isNullOrEmpty()) {
                    val tokenReal = authHeader.removePrefix("Bearer ").trim()
                    var userType = 1
                    var userId = ""

                    try {
                        val parts = tokenReal.split(".")
                        if (parts.size == 3) {
                            val payload = String(Base64.decode(parts[1], Base64.URL_SAFE))
                            val jsonObject = JSONObject(payload)
                            userType = jsonObject.optInt("usertype", 1)
                            userId = jsonObject.optInt("user_id").toString()
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                    LoginResult.Success(userId = userId, token = tokenReal, userType = userType)
                } else {
                    LoginResult.Error("Error: El servidor no devolvió el token.")
                }
            } else {
                LoginResult.Error("Credenciales incorrectas")
            }
        } catch (e: Exception) {
            LoginResult.Error("Error de conexión: ${e.message}")
        }
    }

    private suspend fun syncPasswordIfNeeded(email: String, password: String) {
        try {
            auth.signInWithEmailAndPassword(email, password).await()
            api.resetPassword(ResetPasswordRequest(email, password))
            auth.signOut()
        } catch (e: Exception) {
            // Si Firebase falla, el backend intentará igual
        }
    }
}