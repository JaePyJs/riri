package com.riri.app.data.db.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.riri.app.data.db.entities.Reminder
import kotlinx.coroutines.flow.Flow

@Dao
interface ReminderDao {
    @Query("SELECT * FROM reminders ORDER BY dueDateTime ASC")
    fun observeReminders(): Flow<List<Reminder>>

    @Query("SELECT * FROM reminders WHERE isCompleted = 0 AND dueDateTime >= :now ORDER BY dueDateTime ASC")
    fun observePending(now: Long): Flow<List<Reminder>>

    @Query("SELECT * FROM reminders WHERE isCompleted = 0 AND dueDateTime < :now ORDER BY dueDateTime ASC")
    fun observeOverdue(now: Long): Flow<List<Reminder>>

    @Query("SELECT * FROM reminders WHERE isCompleted = 1 ORDER BY completedAt DESC")
    fun observeCompleted(): Flow<List<Reminder>>

    @Query("SELECT * FROM reminders WHERE dueDateTime BETWEEN :start AND :end ORDER BY dueDateTime ASC")
    suspend fun getRemindersBetween(start: Long, end: Long): List<Reminder>

    @Query("SELECT * FROM reminders")
    suspend fun getAll(): List<Reminder>

    @Query("UPDATE reminders SET procrastinationScore = :score WHERE id = :reminderId")
    suspend fun updateProcrastinationScore(reminderId: Long, score: Float)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(reminder: Reminder): Long

    @Update
    suspend fun update(reminder: Reminder)

    @Delete
    suspend fun delete(reminder: Reminder)
}
