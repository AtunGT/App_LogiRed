package com.arthur.gloria.logired.features.trip.available.di

import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.features.trip.available.data.repository.AvailableTripsRepositoryImpl
import com.arthur.gloria.logired.features.trip.available.domain.repository.AvailableTripsRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AvailableTripsModule {

    @Provides
    @Singleton
    fun provideAvailableTripsRepository(
        api: ApiService
    ): AvailableTripsRepository {
        return AvailableTripsRepositoryImpl(api)
    }
}