package com.arthur.gloria.logired.features.login.registerclient.domain.repository

import com.arthur.gloria.logired.features.login.registerclient.domain.model.ClientData

interface RegisterClientRepository {
    suspend fun register(client: ClientData): Result<Unit>
}