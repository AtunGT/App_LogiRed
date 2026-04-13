package com.arthur.gloria.logired.features.trip.history.di

import com.arthur.gloria.logired.features.trip.history.data.repository.TripHistoryRepositoryImpl
import com.arthur.gloria.logired.features.trip.history.domain.repository.TripHistoryRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class TripHistoryModule {

    @Binds
    @Singleton
    abstract fun bindTripHistoryRepository(
        impl: TripHistoryRepositoryImpl
    ): TripHistoryRepository
}
