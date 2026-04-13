package com.arthur.gloria.logired.features.login.domain.model

sealed class LoginResult {
    data class Success(val userId: String, val token: String, val userType: Int) : LoginResult()
    data class Error(val message: String) : LoginResult()
}