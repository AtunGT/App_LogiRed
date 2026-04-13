package com.arthur.gloria.logired.core.network.model

data class UpdatePasswordRequest(
    val oldPassword: String,
    val newPassword: String
)