package com.arthur.gloria.logired.features.login.registerdriver.domain.model

import android.net.Uri

data class DriverData(
    val name: String,
    val lastname: String,
    val email: String,
    val numberPhone: String,
    val birthdate: String,
    val password: String,
    val confirmPassword: String = "",
    val citywork: String,
    val imageUri: Uri? = null
)