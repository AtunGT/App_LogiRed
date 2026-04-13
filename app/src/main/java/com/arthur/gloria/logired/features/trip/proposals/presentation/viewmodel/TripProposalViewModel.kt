package com.arthur.gloria.logired.features.trip.proposals.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.ProposalStatusRequest
import com.arthur.gloria.logired.core.network.model.ProposalWithDetails
import com.arthur.gloria.logired.features.trip.proposals.presentation.ui.TripProposalsUiState
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
class TripProposalsViewModel @Inject constructor(
    private val apiService: ApiService
) : ViewModel() {

    private val _uiState = MutableStateFlow(TripProposalsUiState())
    val uiState: StateFlow<TripProposalsUiState> = _uiState.asStateFlow()

    private var currentTripId = 0

    fun loadProposals(tripId: Int) {
        currentTripId = tripId
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val response = apiService.getProposalsByRide(tripId)
                if (response.isSuccessful) {
                    val proposals = response.body()?.proposals ?: emptyList()
                    val enriched = proposals.map { proposal ->
                        async {
                            try {
                                val driverResponse = apiService.getUserProfile(proposal.iduser)
                                val carResponse    = apiService.getCarById(proposal.idcar)
                                val driver = driverResponse.body()
                                val car    = carResponse.body()?.car
                                ProposalWithDetails(
                                    proposal        = proposal,
                                    driverName      = "${driver?.name?.trim() ?: ""} ${driver?.lastname?.trim() ?: ""}".trim(),
                                    driverImage     = driver?.image_url?.trim() ?: "",
                                    carBrand        = car?.brand ?: "",
                                    carModel        = car?.model ?: "",
                                    carColor        = car?.color ?: "",
                                    carRegistration = car?.carRegistration ?: "",
                                    carImage        = car?.frontViewImage ?: ""
                                )
                            } catch (e: Exception) {
                                ProposalWithDetails(proposal = proposal)
                            }
                        }
                    }.awaitAll()

                    val resolved = enriched
                        .filter { it.proposal.idstatus == 1 || it.proposal.idstatus == 3 }
                        .associate { it.proposal.id to (it.proposal.idstatus == 1) }

                    _uiState.update { it.copy(isLoading = false, proposals = enriched, resolvedProposals = resolved) }
                } else {
                    _uiState.update { it.copy(isLoading = false, error = "Error al cargar ofertas") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = "Error de conexión: ${e.message}") }
            }
        }
    }

    fun acceptProposal(proposalId: Int) {
        viewModelScope.launch {
            try {
                val response = apiService.updateProposalStatus(proposalId, ProposalStatusRequest(idstatus = 1))
                if (response.isSuccessful) {
                    _uiState.update {
                        it.copy(
                            successMessage    = "¡Oferta aceptada!",
                            resolvedProposals = it.resolvedProposals + (proposalId to true)
                        )
                    }
                } else {
                    _uiState.update { it.copy(error = "Error al aceptar la oferta") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(error = "Error de conexión: ${e.message}") }
            }
        }
    }

    fun rejectProposal(proposalId: Int) {
        viewModelScope.launch {
            try {
                val response = apiService.updateProposalStatus(proposalId, ProposalStatusRequest(idstatus = 3))
                if (response.isSuccessful) {
                    _uiState.update {
                        it.copy(
                            successMessage    = "Oferta rechazada",
                            resolvedProposals = it.resolvedProposals + (proposalId to false)
                        )
                    }
                } else {
                    _uiState.update { it.copy(error = "Error al rechazar la oferta") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(error = "Error de conexión: ${e.message}") }
            }
        }
    }

    fun clearMessages() = _uiState.update { it.copy(successMessage = null, error = null) }
}