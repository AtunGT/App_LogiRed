package com.arthur.gloria.logired.core.network.model

import com.google.gson.annotations.SerializedName

data class TripRequest(
    @SerializedName("origin_city")           val origin_city: String,
    @SerializedName("origin_address")        val origin: String,
    @SerializedName("origin_lat")            val origin_lat: Double,
    @SerializedName("origin_lng")            val origin_lng: Double,
    @SerializedName("destination_address")   val destination: String,
    @SerializedName("destination_lat")       val destination_lat: Double,
    @SerializedName("destination_lng")       val destination_lng: Double,
    @SerializedName("distance_km")           val distance_km: Double,
    val date: String,
    val hour: String,
    @SerializedName("approx_weight") val approx_weight: Int,
    val description: String
)