package com.arthur.gloria.logired.features.trip.accepted.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.features.trip.accepted.domain.usecase.GetAcceptedTripsUseCase
import com.arthur.gloria.logired.features.trip.accepted.presentation.ui.AcceptedTripsUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AcceptedTripsViewModel @Inject constructor(
    private val getAcceptedTripsUseCase: GetAcceptedTripsUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(AcceptedTripsUiState())
    val uiState: StateFlow<AcceptedTripsUiState> = _uiState.asStateFlow()

    init {
        loadTrips()
    }

    fun loadTrips() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            getAcceptedTripsUseCase()
                .onSuccess { trips ->
                    _uiState.update { it.copy(isLoading = false, trips = trips) }
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isLoading = false, error = e.message) }
                }
        }
    }
}