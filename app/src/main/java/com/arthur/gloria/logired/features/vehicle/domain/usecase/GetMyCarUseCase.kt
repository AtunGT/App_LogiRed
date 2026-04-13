package com.arthur.gloria.logired.features.vehicle.domain.usecase

import com.arthur.gloria.logired.core.network.model.Car
import com.arthur.gloria.logired.features.vehicle.domain.model.CarData
import com.arthur.gloria.logired.features.vehicle.domain.repository.CarRepository
import javax.inject.Inject

class GetMyCarsUseCase @Inject constructor(private val repository: CarRepository) {
    suspend operator fun invoke(): Result<List<Car>> = repository.getMyCars()
}

class GetCarByIdUseCase @Inject constructor(private val repository: CarRepository) {
    suspend operator fun invoke(id: Int): Result<Car> = repository.getCarById(id)
}

class CreateCarUseCase @Inject constructor(private val repository: CarRepository) {
    suspend operator fun invoke(carData: CarData): Result<Unit> {
        if (carData.carRegistration.isBlank()) return Result.failure(Exception("La matrícula es obligatoria"))
        if (carData.brand.isBlank()) return Result.failure(Exception("La marca es obligatoria"))
        if (carData.model.isBlank()) return Result.failure(Exception("El modelo es obligatorio"))
        if (carData.color.isBlank()) return Result.failure(Exception("El color es obligatorio"))
        if (carData.maxCapacity <= 0) return Result.failure(Exception("La capacidad debe ser mayor a 0"))
        return repository.createCar(carData)
    }
}

class UpdateCarUseCase @Inject constructor(private val repository: CarRepository) {
    suspend operator fun invoke(id: Int, carData: CarData): Result<Unit> {
        if (carData.carRegistration.isBlank()) return Result.failure(Exception("La matrícula es obligatoria"))
        if (carData.brand.isBlank()) return Result.failure(Exception("La marca es obligatoria"))
        if (carData.model.isBlank()) return Result.failure(Exception("El modelo es obligatorio"))
        if (carData.color.isBlank()) return Result.failure(Exception("El color es obligatorio"))
        if (carData.maxCapacity <= 0) return Result.failure(Exception("La capacidad debe ser mayor a 0"))
        return repository.updateCar(id, carData)
    }
}

class DeleteCarUseCase @Inject constructor(private val repository: CarRepository) {
    suspend operator fun invoke(id: Int): Result<Unit> = repository.deleteCar(id)
}