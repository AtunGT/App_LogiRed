package com.arthur.gloria.logired.core.network.model

import com.google.gson.annotations.SerializedName

data class LoginResponse(
    val message: String? = null,
    val user: UserData? = null
)

data class UserData(
    val id: Int? = null,
    @SerializedName("usertype") val userType: Int? = null
)