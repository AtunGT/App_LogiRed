package com.arthur.gloria.logired.features.login.registerdriver.domain.usecase

import com.arthur.gloria.logired.features.login.registerdriver.domain.model.DriverData
import com.arthur.gloria.logired.features.login.registerdriver.domain.repository.RegisterDriverRepository
import javax.inject.Inject

class RegisterDriverUseCase @Inject constructor(
    private val repository: RegisterDriverRepository
) {
    suspend operator fun invoke(driver: DriverData): Result<Unit> {
        if (driver.name.isBlank())
            return Result.failure(Exception("El nombre es obligatorio"))
        if (driver.lastname.isBlank())
            return Result.failure(Exception("El apellido es obligatorio"))
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(driver.email).matches())
            return Result.failure(Exception("El correo no es válido"))
        if (driver.numberPhone.length != 10 || !driver.numberPhone.all { it.isDigit() })
            return Result.failure(Exception("El teléfono debe tener exactamente 10 dígitos"))
        if (driver.birthdate.isBlank())
            return Result.failure(Exception("La fecha de nacimiento es obligatoria"))
        if (driver.citywork.isBlank())
            return Result.failure(Exception("La ciudad de trabajo es obligatoria"))
        if (driver.password.length < 8)
            return Result.failure(Exception("La contraseña debe tener al menos 8 caracteres"))
        if (!driver.password.any { it.isUpperCase() })
            return Result.failure(Exception("La contraseña debe tener al menos una mayúscula"))
        if (!driver.password.any { !it.isLetterOrDigit() })
            return Result.failure(Exception("La contraseña debe tener al menos un carácter especial"))
        if (driver.password != driver.confirmPassword)
            return Result.failure(Exception("Las contraseñas no coinciden"))
        return repository.register(driver)
    }
}