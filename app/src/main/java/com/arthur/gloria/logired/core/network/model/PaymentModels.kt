package com.arthur.gloria.logired.core.network.model

data class PaymentRequest(
    val ride_id: Int,
    val amount: Double
)

data class PaymentIntentResponse(
    val client_secret: String,
    val payment_intent_id: String
)