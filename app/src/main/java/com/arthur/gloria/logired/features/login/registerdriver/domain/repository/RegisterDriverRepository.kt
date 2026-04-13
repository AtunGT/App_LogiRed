package com.arthur.gloria.logired.features.login.registerdriver.domain.repository

import com.arthur.gloria.logired.features.login.registerdriver.domain.model.DriverData

interface RegisterDriverRepository {
    suspend fun register(driver: DriverData): Result<Unit>
}