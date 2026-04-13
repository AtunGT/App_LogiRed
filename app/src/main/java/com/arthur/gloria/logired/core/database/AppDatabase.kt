package com.arthur.gloria.logired.core.database

import androidx.room.Database
import androidx.room.RoomDatabase
import com.arthur.gloria.logired.core.database.dao.RideLocationDao
import com.arthur.gloria.logired.core.database.entity.RideLocationEntity

@Database(
    entities = [RideLocationEntity::class],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun rideLocationDao(): RideLocationDao
}