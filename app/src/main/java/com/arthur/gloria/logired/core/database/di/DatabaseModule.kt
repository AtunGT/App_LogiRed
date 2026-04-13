package com.arthur.gloria.logired.core.database.di

import android.content.Context
import androidx.room.Room
import com.arthur.gloria.logired.core.database.AppDatabase
import com.arthur.gloria.logired.core.database.dao.RideLocationDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): AppDatabase =
        Room.databaseBuilder(context, AppDatabase::class.java, "logired.db").build()

    @Provides
    fun provideRideLocationDao(db: AppDatabase): RideLocationDao = db.rideLocationDao()
}