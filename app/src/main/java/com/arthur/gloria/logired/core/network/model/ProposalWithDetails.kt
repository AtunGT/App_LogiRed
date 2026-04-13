package com.arthur.gloria.logired.core.network.model

data class ProposalWithDetails(
    val proposal: Proposal,
    val driverName: String = "",
    val driverImage: String = "",
    val carBrand: String = "",
    val carModel: String = "",
    val carColor: String = "",
    val carRegistration: String = "",
    val carImage: String = ""
)