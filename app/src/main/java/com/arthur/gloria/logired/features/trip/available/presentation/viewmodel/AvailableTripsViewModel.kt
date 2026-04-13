package com.arthur.gloria.logired.features.trip.available.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.core.local.TokenManager
import com.arthur.gloria.logired.features.trip.available.domain.usecase.GetAvailableTripsUseCase
import com.arthur.gloria.logired.features.trip.available.presentation.ui.AvailableTripsUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AvailableTripsViewModel @Inject constructor(
    private val getAvailableTripsUseCase: GetAvailableTripsUseCase,
    private val tokenManager: TokenManager
) : ViewModel() {

    private val _uiState = MutableStateFlow(AvailableTripsUiState())
    val uiState: StateFlow<AvailableTripsUiState> = _uiState.asStateFlow()

    init {
        loadCityAndSearch()
    }

    private fun loadCityAndSearch() {
        viewModelScope.launch {
            val city = tokenManager.cityWork.first() ?: ""
            _uiState.update { it.copy(city = city) }
            if (city.isNotBlank()) {
                searchTrips(city)
            }
        }
    }

    fun onCityChange(city: String) = _uiState.update { it.copy(city = city) }

    fun searchTrips(cityOverride: String? = null) {
        val city = (cityOverride ?: uiState.value.city).trim()
        if (city.isBlank()) {
            _uiState.update { it.copy(error = "Ingresa una ciudad") }
            return
        }
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            getAvailableTripsUseCase(city)
                .onSuccess { trips ->
                    _uiState.update { it.copy(isLoading = false, trips = trips) }
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isLoading = false, error = e.message) }
                }
        }
    }

    fun acceptTrip(tripId: Int) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            _uiState.update { it.copy(isLoading = false) }
        }
    }

    fun refresh() = searchTrips()
}