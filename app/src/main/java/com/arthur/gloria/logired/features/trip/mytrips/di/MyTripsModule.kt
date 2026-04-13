package com.arthur.gloria.logired.features.trip.mytrips.di

import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.features.trip.mytrips.data.repository.MyTripsRepositoryImpl
import com.arthur.gloria.logired.features.trip.mytrips.domain.repository.MyTripsRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object MyTripsModule {

    @Provides
    @Singleton
    fun provideMyTripsRepository(
        api: ApiService
    ): MyTripsRepository {
        return MyTripsRepositoryImpl(api)
    }
}