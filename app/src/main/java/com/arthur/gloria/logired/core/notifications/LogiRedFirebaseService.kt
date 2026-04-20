package com.arthur.gloria.logired.core.notifications

import android.util.Log
import com.arthur.gloria.logired.core.local.TokenManager
import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.core.network.model.DeviceTokenRequest
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.launch
import javax.inject.Inject

@AndroidEntryPoint
class LogiRedFirebaseService : FirebaseMessagingService() {

    @Inject lateinit var apiService: ApiService
    @Inject lateinit var tokenManager: TokenManager

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        Log.d(TAG, "FCM message from: ${remoteMessage.from}")

        remoteMessage.notification?.let { notif ->
            NotificationHelper.showTripNotification(
                context  = applicationContext,
                title    = notif.title  ?: "LogiRed",
                message  = notif.body   ?: ""
            )
        }

        if (remoteMessage.data.isNotEmpty()) {
            val title  = remoteMessage.data["title"]   ?: "LogiRed"
            val message = remoteMessage.data["message"] ?: ""
            val type   = remoteMessage.data["type"]    ?: ""
            val rideId = remoteMessage.data["ride_id"]?.toIntOrNull() ?: 0

            Log.d(TAG, "Data message type=$type  msg=$message rideId=$rideId")

            NotificationHelper.showTripNotification(
                context  = applicationContext,
                title    = resolveTitle(type, title),
                message  = message,
                rideId   = rideId,
                type     = type
            )
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d(TAG, "New FCM token: $token")
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val authToken = tokenManager.token.firstOrNull()
                if (!authToken.isNullOrEmpty()) {
                    val deviceName = "${android.os.Build.MANUFACTURER} ${android.os.Build.MODEL}"
                    apiService.registerDeviceToken(
                        DeviceTokenRequest(fcm_token = token, device_name = deviceName)
                    )
                    Log.d(TAG, "Token registrado en backend exitosamente")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error registrando token: ${e.message}")
            }
        }
    }

    private fun resolveTitle(type: String, fallback: String): String = when (type) {
        "trip_accepted"   -> "¡Mudanza aceptada! 🚛"
        "trip_completed"  -> "Mudanza completada ✅"
        "trip_cancelled"  -> "Mudanza cancelada ❌"
        "new_trip_nearby" -> "Nueva mudanza disponible 📦"
        else              -> fallback
    }

    companion object {
        private const val TAG = "LogiRedFCM"
    }
}