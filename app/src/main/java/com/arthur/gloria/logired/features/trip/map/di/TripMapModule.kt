package com.arthur.gloria.logired.features.trip.map.di

import com.arthur.gloria.logired.features.trip.map.data.repository.TripMapRepositoryImpl
import com.arthur.gloria.logired.features.trip.map.domain.repository.TripMapRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class TripMapModule {

    @Binds
    @Singleton
    abstract fun bindTripMapRepository(
        impl: TripMapRepositoryImpl
    ): TripMapRepository
}
