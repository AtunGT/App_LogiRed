package com.arthur.gloria.logired.core.di

import android.content.Context
import androidx.work.WorkManager
import com.arthur.gloria.logired.core.local.ActiveRideStore
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object WorkManagerModule {

    @Provides
    @Singleton
    fun provideWorkManager(@ApplicationContext context: Context): WorkManager =
        WorkManager.getInstance(context)

    @Provides
    @Singleton
    fun provideActiveRideStore(@ApplicationContext context: Context): ActiveRideStore =
        ActiveRideStore(context)
}
