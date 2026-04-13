package com.arthur.gloria.logired.features.trip.request.di

import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.features.trip.request.data.repository.RequestTripRepositoryImpl
import com.arthur.gloria.logired.features.trip.request.domain.repository.RequestTripRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object RequestTripModule {

    @Provides
    @Singleton
    fun provideRequestTripRepository(
        api: ApiService
    ): RequestTripRepository {
        return RequestTripRepositoryImpl(api)
    }
}