package com.arthur.gloria.logired.features.login.registerdriver.presentation.viewmodel

import android.net.Uri
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.features.login.registerdriver.domain.model.DriverData
import com.arthur.gloria.logired.features.login.registerdriver.domain.usecase.RegisterDriverUseCase
import com.arthur.gloria.logired.features.login.registerdriver.presentation.ui.RegisterDriverUiState
import com.google.firebase.auth.FirebaseAuth
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import javax.inject.Inject

@HiltViewModel
class RegisterDriverViewModel @Inject constructor(
    private val registerDriverUseCase: RegisterDriverUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(RegisterDriverUiState())
    val uiState: StateFlow<RegisterDriverUiState> = _uiState.asStateFlow()

    private val auth = FirebaseAuth.getInstance()

    fun onNameChange(v: String)            = _uiState.update { it.copy(name = v) }
    fun onLastnameChange(v: String)        = _uiState.update { it.copy(lastname = v) }
    fun onEmailChange(v: String)           = _uiState.update { it.copy(email = v) }
    fun onPhoneChange(v: String)           = _uiState.update { it.copy(numberPhone = v) }
    fun onBirthdateChange(v: String)       = _uiState.update { it.copy(birthdate = v) }
    fun onPasswordChange(v: String)        = _uiState.update { it.copy(password = v) }
    fun onConfirmPasswordChange(v: String) = _uiState.update { it.copy(confirmPassword = v) }
    fun onCityworkChange(v: String)        = _uiState.update { it.copy(citywork = v) }
    fun onImageSelected(uri: Uri)          = _uiState.update { it.copy(imageUri = uri) }

    fun onRegisterClick() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            val s = uiState.value
            val driver = DriverData(
                name            = s.name,
                lastname        = s.lastname,
                email           = s.email,
                numberPhone     = s.numberPhone,
                birthdate       = s.birthdate,
                password        = s.password,
                confirmPassword = s.confirmPassword,
                citywork        = s.citywork,
                imageUri        = s.imageUri
            )
            registerDriverUseCase(driver)
                .onSuccess {
                    try {
                        auth.createUserWithEmailAndPassword(s.email, s.password).await()
                        auth.setLanguageCode("es")
                        auth.currentUser?.sendEmailVerification()?.await()
                        _uiState.update { it.copy(isLoading = false, emailVerificationSent = true) }
                    } catch (e: Exception) {
                        _uiState.update { it.copy(isLoading = false, error = e.message) }
                    }
                }
                .onFailure { e -> _uiState.update { it.copy(isLoading = false, error = e.message) } }
        }
    }

    fun onNavigationHandled() = _uiState.update { it.copy(registerSuccess = false, emailVerificationSent = false) }
}