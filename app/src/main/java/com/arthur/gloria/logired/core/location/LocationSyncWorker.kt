package com.arthur.gloria.logired.core.location

@HiltWorker
class LocationSyncWorker @AssistedInject constructor(
    @Assisted context: Context,
    @Assisted params: WorkerParameters,
    private val rideLocationDao: RideLocationDao
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val rideId = inputData.getInt("ride_id", -1)
        val token = inputData.getString("token") ?: return Result.failure()

        if (rideId == -1) return Result.failure()

        val pending = rideLocationDao.getUnsynced()
        if (pending.isEmpty()) return Result.success()

        val wsManager = WebSocketManager()
        var connected = false

        // Conectar WS de forma suspendida
        suspendCancellableCoroutine<Unit> { cont ->
            wsManager.onOpen = {
                connected = true
                cont.resume(Unit) {}
            }
            wsManager.onFailure = {
                if (cont.isActive) cont.resume(Unit) {}
            }
            wsManager.connect("wss://logiredapi.redirectme.net/ws/rides/$rideId/publish?token=$token")
        }

        if (!connected) return Result.retry()

        var allSynced = true
        for (location in pending) {
            val msg = JSONObject().apply {
                put("lat", location.lat)
                put("lng", location.lng)
                put("timestamp", location.timestamp / 1000)
                put("phase", location.phase)
            }.toString()

            if (wsManager.send(msg)) {
                rideLocationDao.markSynced(location.id)
            } else {
                allSynced = false
            }
        }

        wsManager.disconnect()
        return if (allSynced) Result.success() else Result.retry()
    }
}