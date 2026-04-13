package com.arthur.gloria.logired.features.trip.mytrips.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.features.trip.mytrips.domain.usecase.CancelTripUseCase
import com.arthur.gloria.logired.features.trip.mytrips.domain.usecase.GetMyTripsUseCase
import com.arthur.gloria.logired.features.trip.mytrips.presentation.ui.MyTripsUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class MyTripsViewModel @Inject constructor(
    private val getMyTripsUseCase: GetMyTripsUseCase,
    private val cancelTripUseCase: CancelTripUseCase,
    private val apiService: ApiService
) : ViewModel() {

    private val _uiState = MutableStateFlow(MyTripsUiState())
    val uiState: StateFlow<MyTripsUiState> = _uiState.asStateFlow()

    init { loadTrips() }

    fun loadTrips() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            getMyTripsUseCase()
                .onSuccess { trips ->
                    _uiState.update { it.copy(isLoading = false, trips = trips) }
                    loadProposalCounts(trips.map { it.id })
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isLoading = false, error = e.message) }
                }
        }
    }

    private fun loadProposalCounts(tripIds: List<Int>) {
        viewModelScope.launch {
            try {
                val counts = tripIds.map { tripId ->
                    async {
                        try {
                            val response = apiService.getProposalsByRide(tripId)
                            val count = response.body()?.proposals?.size ?: 0
                            tripId to count
                        } catch (e: Exception) {
                            tripId to 0
                        }
                    }
                }.awaitAll().toMap()
                _uiState.update { it.copy(proposalCounts = counts) }
            } catch (e: Exception) {

            }
        }
    }

    fun showCancelDialog(tripId: Int) = _uiState.update { it.copy(showCancelDialog = tripId) }
    fun hideCancelDialog()            = _uiState.update { it.copy(showCancelDialog = null) }

    fun cancelTrip(tripId: Int) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, showCancelDialog = null) }
            cancelTripUseCase(tripId)
                .onSuccess {
                    _uiState.update { it.copy(isLoading = false, successMessage = "Viaje cancelado correctamente") }
                    loadTrips()
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isLoading = false, error = e.message) }
                }
        }
    }

    fun clearMessages() = _uiState.update { it.copy(successMessage = null, error = null) }
}