package com.arthur.gloria.logired.core.location

import androidx.hilt.work.HiltWorker
import dagger.assisted.Assisted

@HiltWorker
class WatchdogWorker @AssistedInject constructor(
    @Assisted context: Context,
    @Assisted params: WorkerParameters,
    private val rideLocationDao: RideLocationDao
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val rideId = inputData.getInt("ride_id", -1)
        val token = inputData.getString("token") ?: return Result.failure()
        val phase = inputData.getString("phase") ?: "GOING_TO_ORIGIN"

        if (rideId == -1) return Result.failure()

        val isRunning = isServiceRunning(applicationContext, LocationForegroundService::class.java)

        if (!isRunning) {
            LocationForegroundService.start(applicationContext, rideId, token, phase)
        }

        return Result.success()
    }

    private fun isServiceRunning(context: Context, serviceClass: Class<*>): Boolean {
        val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        @Suppress("DEPRECATION")
        return manager.getRunningServices(Int.MAX_VALUE)
            .any { it.service.className == serviceClass.name }
    }
}