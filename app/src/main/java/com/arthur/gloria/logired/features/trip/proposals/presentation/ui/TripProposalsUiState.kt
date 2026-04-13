package com.arthur.gloria.logired.features.trip.proposals.presentation.ui

import com.arthur.gloria.logired.core.network.model.ProposalWithDetails

data class TripProposalsUiState(
    val proposals: List<ProposalWithDetails> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null,
    val successMessage: String? = null,
    val resolvedProposals: Map<Int, Boolean> = emptyMap()
)