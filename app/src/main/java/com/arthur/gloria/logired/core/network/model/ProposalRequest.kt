package com.arthur.gloria.logired.core.network.model

data class ProposalRequest(
    val price: Int,
    val id_ride: Int,
    val idcar: Int,
    val comment: String
)