package com.arthur.gloria.logired.core.haptic

import android.os.Build
import android.os.VibrationEffect
import androidx.annotation.RequiresApi


enum class HapticEvent {


    TRIP_STARTED,


    ARRIVED_AT_ORIGIN,


    JOURNEY_STARTED,


    ARRIVED_AT_DESTINATION,


    TRIP_COMPLETED,


    WARNING,


    LIGHT_TAP;



    val legacyPattern: LongArray
        get() = when (this) {
            TRIP_STARTED            -> longArrayOf(0, 80, 60, 80)
            ARRIVED_AT_ORIGIN       -> longArrayOf(0, 150, 80, 250)
            JOURNEY_STARTED         -> longArrayOf(0, 80, 60, 80, 60, 80)
            ARRIVED_AT_DESTINATION  -> longArrayOf(0, 250, 80, 400)
            TRIP_COMPLETED          -> longArrayOf(0, 80, 40, 80, 40, 600)
            WARNING                 -> longArrayOf(0, 40, 40, 40, 40, 40)
            LIGHT_TAP               -> longArrayOf(0, 40)
        }


    @RequiresApi(Build.VERSION_CODES.O)
    fun toVibrationEffect(): VibrationEffect = when (this) {

        TRIP_STARTED -> VibrationEffect.createWaveform(
            longArrayOf(0, 80, 60, 80),
             intArrayOf(0, 180, 0, 220),
            -1
        )

        ARRIVED_AT_ORIGIN -> VibrationEffect.createWaveform(
            longArrayOf(0, 150, 80, 250),
            intArrayOf(0, 200, 0, 255),
            -1
        )

        JOURNEY_STARTED -> VibrationEffect.createWaveform(
            longArrayOf(0, 80, 60, 80, 60, 80),
            intArrayOf(0, 180, 0, 210, 0, 255),
            -1
        )

        ARRIVED_AT_DESTINATION -> VibrationEffect.createWaveform(
            longArrayOf(0, 250, 80, 400),
            intArrayOf(0, 200, 0, 255),
            -1
        )

        TRIP_COMPLETED -> VibrationEffect.createWaveform(
            longArrayOf(0, 80, 40, 80, 40, 600),
            intArrayOf(0, 180, 0, 200, 0, 255),
            -1
        )

        WARNING -> VibrationEffect.createWaveform(
            longArrayOf(0, 40, 40, 40, 40, 40),
            intArrayOf(0, 150, 0, 150, 0, 150),
            -1
        )

        LIGHT_TAP -> VibrationEffect.createOneShot(
            40L, VibrationEffect.DEFAULT_AMPLITUDE
        )
    }
}