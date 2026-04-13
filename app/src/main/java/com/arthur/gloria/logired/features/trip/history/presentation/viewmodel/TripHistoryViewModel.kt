package com.arthur.gloria.logired.features.trip.history.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.features.trip.history.domain.usecase.GetTripHistoryUseCase
import com.arthur.gloria.logired.features.trip.history.presentation.ui.TripHistoryUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class TripHistoryViewModel @Inject constructor(
    private val getTripHistoryUseCase: GetTripHistoryUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(TripHistoryUiState())
    val uiState: StateFlow<TripHistoryUiState> = _uiState.asStateFlow()

    fun loadHistory(userType: Int) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            getTripHistoryUseCase(userType)
                .onSuccess { trips ->
                    val finished = trips.filter { it.status == 5 }
                    _uiState.update {
                        it.copy(isLoading = false, trips = finished, filteredTrips = finished)
                    }
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isLoading = false, error = e.message) }
                }
        }
    }

    fun filterByStatus(status: Int?) {
        _uiState.update { state ->
            val filtered = if (status == null) state.trips
            else state.trips.filter { it.status == status }
            state.copy(selectedStatus = status, filteredTrips = filtered)
        }
    }
}