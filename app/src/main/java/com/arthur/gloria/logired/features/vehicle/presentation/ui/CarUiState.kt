package com.arthur.gloria.logired.features.vehicle.presentation.ui

import android.net.Uri
import com.arthur.gloria.logired.core.network.model.Car

data class CarUiState(
    val isLoading: Boolean      = false,
    val cars: List<Car>         = emptyList(),
    val error: String?          = null,
    val successMessage: String? = null,
    val editingCarId: Int?      = null,
    val carRegistration: String = "",
    val brand: String           = "",
    val model: String           = "",
    val year: String = "",
    val color: String           = "",
    val maxCapacity: String     = "",
    val frontViewUri: Uri?      = null,
    val backViewUri: Uri?       = null,
    val platesUri: Uri?         = null,
    val spacesUri: Uri?         = null,
    val showForm: Boolean       = false,
    val showDeleteDialog: Int?  = null
)