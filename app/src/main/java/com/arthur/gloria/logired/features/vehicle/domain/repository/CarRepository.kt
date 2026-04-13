package com.arthur.gloria.logired.features.vehicle.domain.repository

import com.arthur.gloria.logired.core.network.model.Car
import com.arthur.gloria.logired.features.vehicle.domain.model.CarData

interface CarRepository {
    suspend fun getMyCars(): Result<List<Car>>
    suspend fun getCarById(id: Int): Result<Car>
    suspend fun createCar(carData: CarData): Result<Unit>
    suspend fun updateCar(id: Int, carData: CarData): Result<Unit>
    suspend fun deleteCar(id: Int): Result<Unit>
}