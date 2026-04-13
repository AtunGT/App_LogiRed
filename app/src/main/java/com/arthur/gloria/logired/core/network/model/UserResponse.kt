package com.arthur.gloria.logired.core.network.model

data class UserResponse(
    val iduser: Int? = null,
    val name: String? = null,
    val lastname: String? = null,
    val email: String? = null,
    val number_phone: String? = null,
    val birthdate: String? = null,
    val user_type: Int? = null,
    val image_url: String? = null,
    val driver_info: DriverInfo? = null,
    val message: String? = null
)

data class DriverInfo(
    val citywork: String? = null,
    val rating: Int? = null
)