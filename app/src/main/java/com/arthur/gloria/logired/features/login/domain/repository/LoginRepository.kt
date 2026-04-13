package com.arthur.gloria.logired.features.login.domain.repository

import com.arthur.gloria.logired.features.login.domain.model.LoginResult

interface LoginRepository {
    suspend fun login(email: String, password: String): LoginResult
}