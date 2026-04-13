package com.arthur.gloria.logired.core.network.model

data class DeviceTokenRequest(
    val fcm_token: String,
    val device_name: String
)