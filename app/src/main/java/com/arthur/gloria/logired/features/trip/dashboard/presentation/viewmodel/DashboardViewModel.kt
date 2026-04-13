package com.arthur.gloria.logired.features.trip.dashboard.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.features.trip.dashboard.domain.usecase.GetDashboardStatsUseCase
import com.arthur.gloria.logired.features.trip.dashboard.presentation.ui.DashboardUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class DashboardViewModel @Inject constructor(
    private val getDashboardStatsUseCase: GetDashboardStatsUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(DashboardUiState())
    val uiState: StateFlow<DashboardUiState> = _uiState.asStateFlow()

    fun loadStats(userType: Int) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            getDashboardStatsUseCase(userType)
                .onSuccess { trips ->
                    val pending     = trips.count { it.status == 6 }
                    val accepted    = trips.count { it.status == 1 }
                    val completed   = trips.count { it.status == 3 }
                    val cancelled   = trips.count { it.status == 4 }
                    val totalWeight = trips.sumOf { it.approx_weight }
                    val topCity     = trips.groupingBy { it.origin_city }.eachCount().maxByOrNull { it.value }?.key ?: "-"
                    val lastDate    = trips.sortedByDescending { it.created_at }.firstOrNull()?.date ?: "-"

                    _uiState.update {
                        it.copy(
                            isLoading      = false,
                            totalTrips     = trips.size,
                            pendingTrips   = pending,
                            acceptedTrips  = accepted,
                            completedTrips = completed,
                            cancelledTrips = cancelled,
                            totalWeightKg  = totalWeight,
                            topCity        = topCity,
                            lastTripDate   = lastDate
                        )
                    }
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isLoading = false, error = e.message) }
                }
        }
    }
}