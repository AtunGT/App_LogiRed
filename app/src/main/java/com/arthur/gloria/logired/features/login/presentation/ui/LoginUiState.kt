package com.arthur.gloria.logired.features.login.presentation.ui

data class LoginUiState(
    val email: String = "",
    val password: String = "",
    val isLoading: Boolean = false,
    val error: String? = null,
    val loginSuccess: Boolean = false,
    val userType: Int = 1,
    val resetEmailSent: Boolean = false
)