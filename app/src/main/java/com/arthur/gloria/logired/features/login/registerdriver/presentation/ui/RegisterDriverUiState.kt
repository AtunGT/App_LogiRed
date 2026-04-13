package com.arthur.gloria.logired.features.login.registerdriver.presentation.ui

import android.net.Uri

data class RegisterDriverUiState(
    val name: String = "",
    val lastname: String = "",
    val email: String = "",
    val numberPhone: String = "",
    val birthdate: String = "",
    val password: String = "",
    val confirmPassword: String = "",
    val citywork: String = "",
    val imageUri: Uri? = null,
    val isLoading: Boolean = false,
    val error: String? = null,
    val registerSuccess: Boolean = false,
    val emailVerificationSent: Boolean = false
)