package com.arthur.gloria.logired.core.worker

import android.content.Context
import android.util.Log
import androidx.hilt.work.HiltWorker
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.arthur.gloria.logired.core.database.dao.RideLocationDao
import com.arthur.gloria.logired.core.database.entity.RideLocationEntity
import com.arthur.gloria.logired.core.local.ActiveRideStore
import com.arthur.gloria.logired.core.location.LocationForegroundService
import com.arthur.gloria.logired.core.websocket.WebSocketManager
import dagger.assisted.Assisted
import dagger.assisted.AssistedInject
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withTimeoutOrNull
import org.json.JSONObject
import kotlin.coroutines.resume

@HiltWorker
class LocationWatchdogWorker @AssistedInject constructor(
    @Assisted private val context: Context,
    @Assisted workerParams: WorkerParameters,
    private val rideLocationDao: RideLocationDao,
    private val activeRideStore: ActiveRideStore
) : CoroutineWorker(context, workerParams) {

    override suspend fun doWork(): Result {
        Log.d(TAG, "Watchdog ejecutando...")

        val state = activeRideStore.activeRide.first()
        if (state == null) {
            Log.d(TAG, "Sin viaje activo, watchdog no hace nada")
            return Result.success()
        }

        Log.d(TAG, "Viaje activo encontrado: rideId=${state.rideId}, phase=${state.phase}")

        LocationForegroundService.start(
            context = context,
            rideId  = state.rideId,
            token   = state.token,
            phase   = state.phase
        )

        val pending = rideLocationDao.getUnsynced()
        if (pending.isNotEmpty()) {
            Log.d(TAG, "Intentando sincronizar ${pending.size} ubicaciones pendientes...")
            syncPending(state.rideId, state.token, pending)
        } else {
            Log.d(TAG, "Sin ubicaciones pendientes que sincronizar")
        }

        return Result.success()
    }

    private suspend fun syncPending(rideId: Int, token: String, pending: List<RideLocationEntity>) {
        val wsManager = WebSocketManager()

        val connected = withTimeoutOrNull(5_000L) {
            suspendCancellableCoroutine { cont ->
                wsManager.onOpen    = { if (cont.isActive) cont.resume(true) }
                wsManager.onFailure = { if (cont.isActive) cont.resume(false) }
                wsManager.connect("wss://logiredapi.redirectme.net/ws/rides/$rideId/publish?token=$token")
                cont.invokeOnCancellation { wsManager.disconnect() }
            }
        } ?: false

        if (!connected) {
            Log.w(TAG, "No se pudo conectar WS (sin red o timeout), se reintentará después")
            wsManager.disconnect()
            return
        }

        var synced = 0
        for (location in pending) {
            val msg = JSONObject().apply {
                put("lat",       location.lat)
                put("lng",       location.lng)
                put("timestamp", location.timestamp / 1000)
                put("phase",     location.phase)
            }.toString()

            if (wsManager.send(msg)) {
                rideLocationDao.markSynced(location.id)
                synced++
            }
            delay(50L)
        }

        wsManager.disconnect()
        Log.d(TAG, "Sincronización completada: $synced/${pending.size} ubicaciones enviadas")
    }

    companion object {
        const val TAG       = "LocationWatchdog"
        const val WORK_NAME = "logired_location_watchdog"
    }
}
