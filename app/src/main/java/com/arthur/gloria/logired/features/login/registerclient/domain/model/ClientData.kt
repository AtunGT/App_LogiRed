package com.arthur.gloria.logired.features.login.registerclient.domain.model

import android.net.Uri

data class ClientData(
    val name: String,
    val lastname: String,
    val email: String,
    val numberPhone: String,
    val birthdate: String,
    val password: String,
    val confirmPassword: String = "",
    val imageUri: Uri? = null
)