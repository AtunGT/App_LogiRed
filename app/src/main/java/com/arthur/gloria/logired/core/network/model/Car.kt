package com.arthur.gloria.logired.core.network.model

import com.google.gson.annotations.SerializedName

data class Car(
    val id: Int,
    val iduser: Int,
    @SerializedName("car_registration") val carRegistration: String,
    val brand: String,
    val model: String,
    val color: String,
    @SerializedName("max_capacity") val maxCapacity: Int,
    @SerializedName("front_view_image") val frontViewImage: String? = null,
    @SerializedName("back_view_image") val backViewImage: String? = null,
    @SerializedName("plates_image") val platesImage: String? = null,
    @SerializedName("spaces_image") val spacesImage: String? = null
)

data class CarsResponse(val cars: List<Car>?)
data class CarResponse(val car: Car?)