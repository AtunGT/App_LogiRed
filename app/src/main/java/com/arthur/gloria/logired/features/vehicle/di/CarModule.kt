package com.arthur.gloria.logired.features.vehicle.di

import com.arthur.gloria.logired.features.vehicle.data.repository.CarRepositoryImpl
import com.arthur.gloria.logired.features.vehicle.domain.repository.CarRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class CarModule {

    @Binds
    @Singleton
    abstract fun bindCarRepository(impl: CarRepositoryImpl): CarRepository
}