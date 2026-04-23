package com.arthur.gloria.logired.core.work

object WorkManagerScheduler {

    private const val WATCHDOG_TAG = "location_watchdog"
    private const val SYNC_TAG = "location_sync"

    fun scheduleWatchdog(context: Context, rideId: Int, token: String, phase: String) {
        val data = workDataOf(
            "ride_id" to rideId,
            "token" to token,
            "phase" to phase
        )

        // PeriodicWork: se ejecuta cada 15 min (mínimo permitido por Android)
        val request = PeriodicWorkRequestBuilder<WatchdogWorker>(15, TimeUnit.MINUTES)
            .setInputData(data)
            .addTag(WATCHDOG_TAG)
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            WATCHDOG_TAG,
            ExistingPeriodicWorkPolicy.KEEP, // No reiniciar si ya existe
            request
        )
    }

    fun scheduleSync(context: Context, rideId: Int, token: String) {
        val data = workDataOf("ride_id" to rideId, "token" to token)

        // OneTimeWork: lanzar sync inmediato (al reconectar red, por ejemplo)
        val request = OneTimeWorkRequestBuilder<LocationSyncWorker>()
            .setInputData(data)
            .addTag(SYNC_TAG)
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 30, TimeUnit.SECONDS)
            .build()

        WorkManager.getInstance(context).enqueueUniqueWork(
            SYNC_TAG,
            ExistingWorkPolicy.REPLACE,
            request
        )
    }

    fun cancelAll(context: Context) {
        WorkManager.getInstance(context).apply {
            cancelAllWorkByTag(WATCHDOG_TAG)
            cancelAllWorkByTag(SYNC_TAG)
        }
    }
}