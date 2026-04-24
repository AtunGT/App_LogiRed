package com.arthur.gloria.logired.core.location

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat.getSystemService
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.lifecycleScope
import com.arthur.gloria.logired.R
import com.arthur.gloria.logired.core.database.dao.RideLocationDao
import com.arthur.gloria.logired.core.database.entity.RideLocationEntity
import com.arthur.gloria.logired.core.websocket.WebSocketManager
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.arthur.gloria.logired.core.local.ActiveRideStore
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import org.json.JSONObject
import javax.inject.Inject

@AndroidEntryPoint
class LocationForegroundService : LifecycleService() {

    @Inject lateinit var rideLocationDao: RideLocationDao
    @Inject lateinit var activeRideStore: ActiveRideStore

    private val wsManager = WebSocketManager()
    private lateinit var fusedClient: FusedLocationProviderClient

    private var rideId: Int = -1
    private var token: String = ""
    private var currentPhase: String = "GOING_TO_ORIGIN"
    private var isWsConnected = false
    private var isStarted = false

    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            val loc = result.lastLocation ?: return
            handleNewLocation(loc.latitude, loc.longitude)
        }
    }

    companion object {
        private const val TAG = "LocationService"
        private const val CHANNEL_ID = "location_tracking"
        private const val NOTIFICATION_ID = 1001

        const val ACTION_START = "START_TRACKING"
        const val ACTION_STOP = "STOP_TRACKING"
        const val ACTION_UPDATE_PHASE = "UPDATE_PHASE"

        const val EXTRA_RIDE_ID = "ride_id"
        const val EXTRA_TOKEN = "token"
        const val EXTRA_PHASE = "phase"

        fun start(context: Context, rideId: Int, token: String, phase: String) {
            val intent = Intent(context, LocationForegroundService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_RIDE_ID, rideId)
                putExtra(EXTRA_TOKEN, token)
                putExtra(EXTRA_PHASE, phase)
            }
            context.startForegroundService(intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, LocationForegroundService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }

        fun updatePhase(context: Context, phase: String) {
            val intent = Intent(context, LocationForegroundService::class.java).apply {
                action = ACTION_UPDATE_PHASE
                putExtra(EXTRA_PHASE, phase)
            }
            context.startService(intent)
        }
    }

    override fun onCreate() {
        super.onCreate()
        fusedClient = LocationServices.getFusedLocationProviderClient(this)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        when (intent?.action) {
            ACTION_START -> {
                if (isStarted) {
                    Log.d(TAG, "Servicio ya iniciado, ignorando ACTION_START duplicado")
                    return START_STICKY
                }
                rideId = intent.getIntExtra(EXTRA_RIDE_ID, -1)
                token  = intent.getStringExtra(EXTRA_TOKEN) ?: ""
                currentPhase = intent.getStringExtra(EXTRA_PHASE) ?: "GOING_TO_ORIGIN"
                if (rideId == -1 || token.isEmpty()) {
                    stopSelf()
                    return START_NOT_STICKY
                }
                isStarted = true
                startForeground(NOTIFICATION_ID, buildNotification())
                lifecycleScope.launch {
                    activeRideStore.saveActiveRide(rideId, token, currentPhase)
                }
                connectWebSocket()
                startLocationUpdates()
            }
            ACTION_UPDATE_PHASE -> {
                currentPhase = intent.getStringExtra(EXTRA_PHASE) ?: currentPhase
                Log.d(TAG, "Fase actualizada a: $currentPhase")
                lifecycleScope.launch {
                    activeRideStore.updatePhase(currentPhase)
                }
            }
            ACTION_STOP -> stopTracking()
            else -> {
                if (isStarted) return START_STICKY
                Log.d(TAG, "Servicio reiniciado por Android (intent null), recuperando estado...")
                lifecycleScope.launch {
                    val state = activeRideStore.activeRide.first()
                    if (state != null) {
                        rideId = state.rideId
                        token  = state.token
                        currentPhase = state.phase
                        isStarted = true
                        startForeground(NOTIFICATION_ID, buildNotification())
                        connectWebSocket()
                        startLocationUpdates()
                        Log.d(TAG, "Servicio restaurado: rideId=$rideId, phase=$currentPhase")
                    } else {
                        Log.w(TAG, "Sin viaje activo en DataStore, deteniendo servicio")
                        stopSelf()
                    }
                }
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent): IBinder? {
        super.onBind(intent)
        return null
    }

    @SuppressLint("MissingPermission")
    private fun startLocationUpdates() {
        val request = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            3000L
        ).setMinUpdateIntervalMillis(2000L).build()

        fusedClient.requestLocationUpdates(request, locationCallback, Looper.getMainLooper())
    }

    private fun connectWebSocket() {
        wsManager.onOpen = {
            isWsConnected = true
            Log.d(TAG, "WS publish conectado")
            lifecycleScope.launch {
                val pending = rideLocationDao.getUnsynced()
                Log.d(TAG, "Sincronizando ${pending.size} posiciones pendientes")
                for (location in pending) {
                    val msg = JSONObject().apply {
                        put("lat", location.lat)
                        put("lng", location.lng)
                        put("timestamp", location.timestamp / 1000)
                        put("phase", location.phase)
                    }.toString()
                    if (wsManager.send(msg)) {
                        rideLocationDao.markSynced(location.id)
                    }
                }
            }
        }
        wsManager.onFailure = {
            isWsConnected = false
            Log.w(TAG, "WS publish falló: $it")
            lifecycleScope.launch {
                delay(3000)
                if (rideId != -1) connectWebSocket()
            }
        }
        wsManager.onClosed = {
            isWsConnected = false
            Log.d(TAG, "WS publish cerrado")
        }

        wsManager.connect("wss://logiredapi.redirectme.net/ws/rides/$rideId/publish?token=$token")
    }

    private fun handleNewLocation(lat: Double, lng: Double) {
        val timestamp = System.currentTimeMillis()
        val message = JSONObject().apply {
            put("lat", lat)
            put("lng", lng)
            put("timestamp", timestamp / 1000)
            put("phase", currentPhase)
        }.toString()

        lifecycleScope.launch {
            val sent = if (isWsConnected) wsManager.send(message) else false
            rideLocationDao.insert(
                RideLocationEntity(
                    rideId = rideId,
                    lat = lat,
                    lng = lng,
                    timestamp = timestamp,
                    phase = currentPhase,
                    synced = sent
                )
            )
        }
    }

    private fun stopTracking() {
        isStarted = false
        lifecycleScope.launch {
            activeRideStore.clearActiveRide()
        }
        fusedClient.removeLocationUpdates(locationCallback)
        wsManager.disconnect()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        fusedClient.removeLocationUpdates(locationCallback)
        wsManager.disconnect()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Seguimiento de viaje",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Mantiene el viaje activo en segundo plano"
            }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Viaje en curso")
            .setContentText("Enviando tu ubicación al cliente")
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
}