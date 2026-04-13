package com.arthur.gloria.logired.core.local

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "auth_prefs")

class TokenManager @Inject constructor(
    private val context: Context
) {
    companion object {
        private val TOKEN_KEY     = stringPreferencesKey("jwt_token")
        private val USER_TYPE_KEY = intPreferencesKey("user_type")
        private val CITY_KEY      = stringPreferencesKey("city_work")
    }

    val token: Flow<String?>    = context.dataStore.data.map { it[TOKEN_KEY] }
    val userType: Flow<Int?>    = context.dataStore.data.map { it[USER_TYPE_KEY] }
    val cityWork: Flow<String?> = context.dataStore.data.map { it[CITY_KEY] }

    suspend fun saveAuthData(token: String, type: Int, cityWork: String = "") {
        context.dataStore.edit {
            it[TOKEN_KEY]     = token
            it[USER_TYPE_KEY] = type
            it[CITY_KEY]      = cityWork
        }
    }

    suspend fun clearData() {
        context.dataStore.edit { it.clear() }
    }
}