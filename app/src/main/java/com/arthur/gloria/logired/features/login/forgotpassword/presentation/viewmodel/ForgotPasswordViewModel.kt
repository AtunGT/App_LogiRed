package com.arthur.gloria.logired.features.login.forgotpassword.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.firebase.auth.FirebaseAuth
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import javax.inject.Inject

data class ForgotPasswordUiState(
    val email: String = "",
    val isLoading: Boolean = false,
    val error: String? = null,
    val emailSent: Boolean = false
)

@HiltViewModel
class ForgotPasswordViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(ForgotPasswordUiState())
    val uiState: StateFlow<ForgotPasswordUiState> = _uiState.asStateFlow()

    private val auth = FirebaseAuth.getInstance()

    fun onEmailChange(v: String) = _uiState.update { it.copy(email = v, error = null) }

    fun onSendClick() {
        val email = uiState.value.email.trim()
        if (email.isBlank()) {
            _uiState.update { it.copy(error = "Ingresa tu correo electrónico") }
            return
        }
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                auth.setLanguageCode("es")
                auth.sendPasswordResetEmail(email).await()
                _uiState.update { it.copy(isLoading = false, emailSent = true) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = "Correo no encontrado") }
            }
        }
    }
}