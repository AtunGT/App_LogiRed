package com.arthur.gloria.logired.core.network.model

import com.google.gson.annotations.SerializedName

data class Trip(
    val id: Int = 0,
    @SerializedName("origin_address")
    val origin: String = "",
    @SerializedName("origin_city")
    val origin_city: String = "",
    @SerializedName("destination_address")
    val destination: String = "",
    val date: String = "",
    val hour: String = "",
    @SerializedName("approx_weight")
    val approx_weight: Int = 0,
    val description: String = "",
    @SerializedName("idstatus")
    val status: Int = 0,
    @SerializedName("id_client")
    val client_id: Int = 0,
    @SerializedName("origin_lat")
    val origin_lat: Double = 0.0,
    @SerializedName("origin_lng")
    val origin_lng: Double = 0.0,
    @SerializedName("destination_lat")
    val destination_lat: Double = 0.0,
    @SerializedName("destination_lng")
    val destination_lng: Double = 0.0,
    @SerializedName("id_driver")
    val driver_id: Int? = null,
    val created_at: String = "")