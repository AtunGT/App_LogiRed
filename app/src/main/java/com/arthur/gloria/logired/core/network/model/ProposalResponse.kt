package com.arthur.gloria.logired.core.network.model

data class Proposal(
    val id: Int,
    val price: Int,
    val comment: String,
    val iduser: Int,
    val id_ride: Int,
    val idstatus: Int,
    val idcar: Int
)

data class ProposalsResponse(
    val proposals: List<Proposal>?,
    val total: Int?
)