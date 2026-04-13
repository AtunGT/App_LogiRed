package com.arthur.gloria.logired.features.trip.accepted.di

import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.features.trip.accepted.data.repository.AcceptedTripsRepositoryImpl
import com.arthur.gloria.logired.features.trip.accepted.domain.repository.AcceptedTripsRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AcceptedTripsModule {

    @Provides
    @Singleton
    fun provideAcceptedTripsRepository(
        api: ApiService
    ): AcceptedTripsRepository {
        return AcceptedTripsRepositoryImpl(api)
    }
}