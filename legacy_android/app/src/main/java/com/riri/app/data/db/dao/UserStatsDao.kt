package com.riri.app.data.db.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.riri.app.data.db.entities.UserStats

@Dao
interface UserStatsDao {
    @Query("SELECT * FROM user_stats WHERE weekStartDate = :weekStartDate LIMIT 1")
    suspend fun getWeek(weekStartDate: Long): UserStats?

    @Query("SELECT * FROM user_stats ORDER BY weekStartDate DESC LIMIT 1")
    suspend fun getLatest(): UserStats?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(stats: UserStats)

    @Query("SELECT * FROM user_stats ORDER BY weekStartDate DESC")
    fun getAll(): kotlinx.coroutines.flow.Flow<List<UserStats>>
}
