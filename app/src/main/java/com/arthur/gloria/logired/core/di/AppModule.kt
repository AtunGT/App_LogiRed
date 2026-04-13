package com.arthur.gloria.logired.core.di

import android.content.Context
import com.arthur.gloria.logired.core.local.TokenManager
import com.arthur.gloria.logired.features.login.data.repository.LoginRepositoryImpl
import com.arthur.gloria.logired.features.login.domain.repository.LoginRepository
import com.arthur.gloria.logired.features.login.registerclient.data.repository.RegisterClientRepositoryImpl
import com.arthur.gloria.logired.features.login.registerclient.domain.repository.RegisterClientRepository
import com.arthur.gloria.logired.features.login.registerdriver.data.repository.RegisterDriverRepositoryImpl
import com.arthur.gloria.logired.features.login.registerdriver.domain.repository.RegisterDriverRepository
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class AppModule {

    @Binds
    @Singleton
    abstract fun bindLoginRepository(impl: LoginRepositoryImpl): LoginRepository

    @Binds
    @Singleton
    abstract fun bindRegisterClientRepository(impl: RegisterClientRepositoryImpl): RegisterClientRepository

    @Binds
    @Singleton
    abstract fun bindRegisterDriverRepository(impl: RegisterDriverRepositoryImpl): RegisterDriverRepository

    companion object {
        @Provides
        @Singleton
        fun provideTokenManager(@ApplicationContext context: Context): TokenManager {
            return TokenManager(context)
        }
    }
}