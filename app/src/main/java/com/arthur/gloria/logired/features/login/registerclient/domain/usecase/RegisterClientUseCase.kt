package com.arthur.gloria.logired.features.login.registerclient.domain.usecase

import com.arthur.gloria.logired.features.login.registerclient.domain.model.ClientData
import com.arthur.gloria.logired.features.login.registerclient.domain.repository.RegisterClientRepository
import javax.inject.Inject

class RegisterClientUseCase @Inject constructor(
    private val repository: RegisterClientRepository
) {
    suspend operator fun invoke(client: ClientData): Result<Unit> {
        if (client.name.isBlank())
            return Result.failure(Exception("El nombre es obligatorio"))
        if (client.lastname.isBlank())
            return Result.failure(Exception("El apellido es obligatorio"))
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(client.email).matches())
            return Result.failure(Exception("El correo no es válido"))
        if (client.numberPhone.length != 10 || !client.numberPhone.all { it.isDigit() })
            return Result.failure(Exception("El teléfono debe tener exactamente 10 dígitos"))
        if (client.birthdate.isBlank())
            return Result.failure(Exception("La fecha de nacimiento es obligatoria"))
        if (client.password.length < 8)
            return Result.failure(Exception("La contraseña debe tener al menos 8 caracteres"))
        if (!client.password.any { it.isUpperCase() })
            return Result.failure(Exception("La contraseña debe tener al menos una mayúscula"))
        if (!client.password.any { !it.isLetterOrDigit() })
            return Result.failure(Exception("La contraseña debe tener al menos un carácter especial"))
        if (client.password != client.confirmPassword)
            return Result.failure(Exception("Las contraseñas no coinciden"))
        return repository.register(client)
    }
}