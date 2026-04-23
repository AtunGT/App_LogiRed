package com.arthur.gloria.logired.core.database.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "ride_locations",
    indices = [Index(value = ["rideId"])]
)
data class RideLocationEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val rideId: Int,
    val lat: Double,
    val lng: Double,
    val timestamp: Long,
    val phase: String = "GOING_TO_ORIGIN",
    val synced: Boolean = false
)
