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

    /**
     * Observa en tiempo real la última posición registrada para un viaje.
     * Usado por el ViewModel del conductor para actualizar la UI desde Room DB.
     */
    @Query("SELECT * FROM ride_locations WHERE rideId = :rideId ORDER BY timestamp DESC LIMIT 1")
    fun observe(rideId: Int): Flow<RideLocationEntity?>

    /**
     * Lee una vez la última posición registrada para un viaje.
     */
    @Query("SELECT * FROM ride_locations WHERE rideId = :rideId ORDER BY timestamp DESC LIMIT 1")
    suspend fun getOnce(rideId: Int): RideLocationEntity?

    /**
     * Devuelve todas las posiciones pendientes de sincronizar, en orden cronológico.
     */
    @Query("SELECT * FROM ride_locations WHERE synced = 0 ORDER BY timestamp ASC")
    suspend fun getUnsynced(): List<RideLocationEntity>

    /**
     * Marca una posición como sincronizada exitosamente.
     */
    @Query("UPDATE ride_locations SET synced = 1 WHERE id = :id")
    suspend fun markSynced(id: Long)

    /**
     * Elimina todas las posiciones de un viaje (al finalizar).
     */
    @Query("DELETE FROM ride_locations WHERE rideId = :rideId")
    suspend fun deleteByRide(rideId: Int)
}
