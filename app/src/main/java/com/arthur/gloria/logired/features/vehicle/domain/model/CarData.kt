package com.arthur.gloria.logired.features.vehicle.domain.model

import android.net.Uri

data class CarData(
    val carRegistration: String,
    val brand: String,
    val model: String,
    val color: String,
    val maxCapacity: Int,
    val frontViewUri: Uri? = null,
    val backViewUri: Uri? = null,
    val platesUri: Uri? = null,
    val spacesUri: Uri? = null
)