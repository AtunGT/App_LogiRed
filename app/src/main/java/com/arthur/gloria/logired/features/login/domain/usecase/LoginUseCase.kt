package com.arthur.gloria.logired.features.login.domain.usecase

import com.arthur.gloria.logired.features.login.domain.model.LoginResult
import com.arthur.gloria.logired.features.login.domain.repository.LoginRepository
import javax.inject.Inject

class LoginUseCase @Inject constructor(
    private val repository: LoginRepository
) {
    suspend operator fun invoke(email: String, password: String): LoginResult {
        if (email.isBlank() || password.isBlank()) {
            return LoginResult.Error("Correo y contraseña son obligatorios")
        }
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            return LoginResult.Error("Correo no válido")
        }
        if (password.length < 6) {
            return LoginResult.Error("La contraseña debe tener al menos 6 caracteres")
        }
        return repository.login(email, password)
    }
}