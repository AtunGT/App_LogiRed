package com.arthur.gloria.logired.core.local

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.activeRideDataStore by preferencesDataStore(name = "active_ride_state")

class ActiveRideStore(private val context: Context) {

    companion object {
        private val KEY_RIDE_ID   = intPreferencesKey("ride_id")
        private val KEY_TOKEN     = stringPreferencesKey("token")
        private val KEY_PHASE     = stringPreferencesKey("phase")
        private val KEY_IS_ACTIVE = booleanPreferencesKey("is_active")
    }

    val activeRide: Flow<ActiveRideState?> = context.activeRideDataStore.data.map { prefs ->
        val isActive = prefs[KEY_IS_ACTIVE] == true
        if (isActive) {
            val rideId = prefs[KEY_RIDE_ID] ?: -1
            val token  = prefs[KEY_TOKEN]   ?: ""
            if (rideId != -1 && token.isNotEmpty()) {
                ActiveRideState(
                    rideId = rideId,
                    token  = token,
                    phase  = prefs[KEY_PHASE] ?: "GOING_TO_ORIGIN"
                )
            } else null
        } else null
    }

    suspend fun saveActiveRide(rideId: Int, token: String, phase: String) {
        context.activeRideDataStore.edit { prefs ->
            prefs[KEY_RIDE_ID]   = rideId
            prefs[KEY_TOKEN]     = token
            prefs[KEY_PHASE]     = phase
            prefs[KEY_IS_ACTIVE] = true
        }
    }

    suspend fun updatePhase(phase: String) {
        context.activeRideDataStore.edit { prefs ->
            prefs[KEY_PHASE] = phase
        }
    }

    suspend fun clearActiveRide() {
        context.activeRideDataStore.edit { prefs ->
            prefs[KEY_IS_ACTIVE] = false
            prefs.remove(KEY_RIDE_ID)
            prefs.remove(KEY_TOKEN)
            prefs.remove(KEY_PHASE)
        }
    }
}

data class ActiveRideState(
    val rideId: Int,
    val token: String,
    val phase: String
)