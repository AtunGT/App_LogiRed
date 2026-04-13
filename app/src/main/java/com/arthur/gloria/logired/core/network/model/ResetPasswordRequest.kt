package com.arthur.gloria.logired.core.network.model

data class ResetPasswordRequest(
    val email: String,
    val newPassword: String
)