package com.arthur.gloria.logired.core.database.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.arthur.gloria.logired.core.database.entity.RideLocationEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface RideLocationDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(location: RideLocationEntity)

    @Query("SELECT * FROM ride_locations WHERE rideId = :rideId ORDER BY timestamp DESC LIMIT 1")
    fun observe(rideId: Int): Flow<RideLocationEntity?>

    @Query("SELECT * FROM ride_locations WHERE rideId = :rideId ORDER BY timestamp DESC LIMIT 1")
    suspend fun getOnce(rideId: Int): RideLocationEntity?

    @Query("SELECT * FROM ride_locations WHERE synced = 0 ORDER BY timestamp ASC")
    suspend fun getUnsynced(): List<RideLocationEntity>

    @Query("UPDATE ride_locations SET synced = 1 WHERE id = :id")
    suspend fun markSynced(id: Long)

    @Query("DELETE FROM ride_locations WHERE rideId = :rideId")
    suspend fun deleteByRide(rideId: Int)
}
