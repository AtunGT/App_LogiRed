package com.arthur.gloria.logired.features.trip.driverdetail.presentation.ui

import com.arthur.gloria.logired.core.network.model.Car
import com.arthur.gloria.logired.core.network.model.Trip

data class DriverTripDetailUiState(
    val trip: Trip? = null,
    val cars: List<Car> = emptyList(),
    val selectedCar: Car? = null,
    val price: String = "",
    val comment: String = "",
    val isLoading: Boolean = false,
    val isSending: Boolean = false,
    val error: String? = null,
    val proposalSent: Boolean = false,
    val sentPrice: String = "",
    val sentComment: String = "",
    val sentCarName: String = ""
)