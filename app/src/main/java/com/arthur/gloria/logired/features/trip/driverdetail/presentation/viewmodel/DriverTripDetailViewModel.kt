package com.arthur.gloria.logired.features.trip.driverdetail.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.Car
import com.arthur.gloria.logired.core.network.model.ProposalRequest
import com.arthur.gloria.logired.features.trip.driverdetail.presentation.ui.DriverTripDetailUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class DriverTripDetailViewModel @Inject constructor(
    private val apiService: ApiService
) : ViewModel() {

    private val _uiState = MutableStateFlow(DriverTripDetailUiState())
    val uiState: StateFlow<DriverTripDetailUiState> = _uiState.asStateFlow()

    fun loadTrip(tripId: Int) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val tripResponse = apiService.getRideById(tripId)
                val carsResponse = apiService.getMyCars()
                val cars = carsResponse.body()?.cars ?: emptyList()
                if (tripResponse.isSuccessful) {
                    _uiState.update {
                        it.copy(
                            isLoading   = false,
                            trip        = tripResponse.body()?.ride,
                            cars        = cars,
                            selectedCar = cars.firstOrNull()
                        )
                    }
                } else {
                    _uiState.update { it.copy(isLoading = false, error = "Error al cargar el viaje") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = "Error de conexión: ${e.message}") }
            }
        }
    }

    fun onPriceChange(v: String)    = _uiState.update { it.copy(price = v) }
    fun onCommentChange(v: String)  = _uiState.update { it.copy(comment = v) }
    fun onCarSelected(car: Car)     = _uiState.update { it.copy(selectedCar = car) }

    fun onSendProposal() {
        val s = uiState.value
        val price = s.price.toIntOrNull()
        if (price == null || price <= 0) {
            _uiState.update { it.copy(error = "Ingresa un costo válido") }
            return
        }
        if (s.selectedCar == null) {
            _uiState.update { it.copy(error = "Selecciona un vehículo") }
            return
        }
        if (s.trip == null) return

        viewModelScope.launch {
            _uiState.update { it.copy(isSending = true, error = null) }
            try {
                val response = apiService.sendProposal(
                    ProposalRequest(
                        price   = price,
                        id_ride = s.trip.id,
                        idcar   = s.selectedCar.id,
                        comment = s.comment
                    )
                )
                if (response.isSuccessful) {
                    _uiState.update {
                        it.copy(
                            isSending    = false,
                            proposalSent = true,
                            sentPrice    = s.price,
                            sentComment  = s.comment,
                            sentCarName  = "${s.selectedCar.brand} ${s.selectedCar.model} - ${s.selectedCar.color}"
                        )
                    }
                } else {
                    _uiState.update { it.copy(isSending = false, error = "Error al enviar la oferta") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(isSending = false, error = "Error de conexión: ${e.message}") }
            }
        }
    }
}