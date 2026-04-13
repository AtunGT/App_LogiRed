package com.arthur.gloria.logired.core.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "ride_locations")
data class RideLocationEntity(
    @PrimaryKey val rideId: Int,
    val lat: Double,
    val lng: Double,
    val timestamp: Long,
    val synced: Boolean = true
)