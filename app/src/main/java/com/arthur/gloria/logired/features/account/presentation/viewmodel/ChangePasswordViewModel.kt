package com.arthur.gloria.logired.features.account.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.core.local.TokenManager
import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.UpdatePasswordRequest
import com.arthur.gloria.logired.features.account.presentation.ui.ChangePasswordUiState
import com.google.firebase.auth.EmailAuthProvider
import com.google.firebase.auth.FirebaseAuth
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import javax.inject.Inject

@HiltViewModel
class ChangePasswordViewModel @Inject constructor(
    private val apiService: ApiService,
    private val tokenManager: TokenManager
) : ViewModel() {

    private val _uiState = MutableStateFlow(ChangePasswordUiState())
    val uiState: StateFlow<ChangePasswordUiState> = _uiState.asStateFlow()

    private val auth = FirebaseAuth.getInstance()

    fun onOldPasswordChange(v: String)     = _uiState.update { it.copy(oldPassword = v, error = null) }
    fun onNewPasswordChange(v: String)     = _uiState.update { it.copy(newPassword = v, error = null) }
    fun onConfirmPasswordChange(v: String) = _uiState.update { it.copy(confirmPassword = v, error = null) }

    fun onSaveClick() {
        val s = uiState.value
        if (s.oldPassword.isBlank()) {
            _uiState.update { it.copy(error = "Ingresa tu contraseña actual") }
            return
        }
        if (s.newPassword.length < 6) {
            _uiState.update { it.copy(error = "La nueva contraseña debe tener al menos 6 caracteres") }
            return
        }
        if (s.newPassword != s.confirmPassword) {
            _uiState.update { it.copy(error = "Las contraseñas no coinciden") }
            return
        }
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val email = getUserEmail()
                if (email.isBlank()) {
                    _uiState.update { it.copy(isLoading = false, error = "No se pudo obtener el correo del usuario") }
                    return@launch
                }

                auth.signInWithEmailAndPassword(email, s.oldPassword).await()

                val user = auth.currentUser
                val credential = EmailAuthProvider.getCredential(email, s.oldPassword)
                user?.reauthenticate(credential)?.await()
                user?.updatePassword(s.newPassword)?.await()

                val response = apiService.updatePassword(
                    UpdatePasswordRequest(
                        oldPassword = s.oldPassword,
                        newPassword = s.newPassword
                    )
                )

                if (response.isSuccessful) {
                    _uiState.update { it.copy(isLoading = false, success = true) }
                } else {
                    _uiState.update { it.copy(isLoading = false, error = "Error al actualizar contraseña") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = "Contraseña actual incorrecta") }
            }
        }
    }

    private suspend fun getUserEmail(): String {
        return try {
            val userId = extractUserIdFromToken()
            val response = apiService.getUserProfile(userId)
            response.body()?.email?.trim() ?: ""
        } catch (e: Exception) {
            ""
        }
    }

    private suspend fun extractUserIdFromToken(): Int {
        return try {
            val token = tokenManager.token.first() ?: ""
            val payload = token.split(".")[1]
            val decoded = android.util.Base64.decode(payload, android.util.Base64.URL_SAFE or android.util.Base64.NO_PADDING)
            org.json.JSONObject(String(decoded)).optInt("user_id", -1)
        } catch (e: Exception) {
            -1
        }
    }
}