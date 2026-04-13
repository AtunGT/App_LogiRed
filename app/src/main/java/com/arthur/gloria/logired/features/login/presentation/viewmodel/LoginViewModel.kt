package com.arthur.gloria.logired.features.login.presentation.viewmodel

import android.os.Build
import android.util.Base64
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.core.local.TokenManager
import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.DeviceTokenRequest
import com.arthur.gloria.logired.features.login.domain.model.LoginResult
import com.arthur.gloria.logired.features.login.domain.usecase.LoginUseCase
import com.arthur.gloria.logired.features.login.presentation.ui.LoginUiState
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.messaging.FirebaseMessaging
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import org.json.JSONObject
import javax.inject.Inject

@HiltViewModel
class LoginViewModel @Inject constructor(
    private val loginUseCase: LoginUseCase,
    private val tokenManager: TokenManager,
    private val apiService: ApiService
) : ViewModel() {

    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    private val auth = FirebaseAuth.getInstance()

    fun onEmailChange(value: String) = _uiState.update { it.copy(email = value) }
    fun onPasswordChange(value: String) = _uiState.update { it.copy(password = value) }

    fun onLoginClick() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            when (val result = loginUseCase(uiState.value.email, uiState.value.password)) {
                is LoginResult.Success -> {
                    val cityWork = extractCityFromJwt(result.token)
                    tokenManager.saveAuthData(result.token, result.userType, cityWork)
                    registerFcmToken()
                    _uiState.update {
                        it.copy(isLoading = false, loginSuccess = true, userType = result.userType)
                    }
                }
                is LoginResult.Error -> {
                    _uiState.update { it.copy(isLoading = false, error = result.message) }
                }
            }
        }
    }

    fun onForgotPassword() {
        val email = uiState.value.email
        if (email.isBlank()) {
            _uiState.update { it.copy(error = "Ingresa tu correo electrónico primero") }
            return
        }
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                auth.setLanguageCode("es")
                auth.sendPasswordResetEmail(email).await()
                _uiState.update { it.copy(isLoading = false, resetEmailSent = true) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = e.message) }
            }
        }
    }

    fun onResetEmailHandled() = _uiState.update { it.copy(resetEmailSent = false) }

    private fun extractCityFromJwt(token: String): String {
        return try {
            val payload = token.split(".")[1]
            val decoded = Base64.decode(payload, Base64.URL_SAFE or Base64.NO_PADDING)
            val json = JSONObject(String(decoded))
            json.optString("citywork", "")
        } catch (e: Exception) {
            ""
        }
    }

    private suspend fun registerFcmToken() {
        try {
            val fcmToken = FirebaseMessaging.getInstance().token.await()
            val deviceName = "${Build.MANUFACTURER} ${Build.MODEL}"
            apiService.registerDeviceToken(DeviceTokenRequest(fcm_token = fcmToken, device_name = deviceName))
        } catch (e: Exception) {
        }
    }

    fun onNavigationHandled() = _uiState.update { it.copy(loginSuccess = false) }
}