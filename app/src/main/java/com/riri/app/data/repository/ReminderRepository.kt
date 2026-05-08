package com.riri.app.data.repository

import com.riri.app.data.db.dao.ReminderDao
import com.riri.app.data.db.entities.Reminder
import kotlinx.coroutines.flow.Flow

class ReminderRepository(
    private val reminderDao: ReminderDao,
    private val statsRepository: StatsRepository
) {
    fun observeReminders(): Flow<List<Reminder>> = reminderDao.observeReminders()

    suspend fun getRemindersBetween(start: Long, end: Long): List<Reminder> {
        return reminderDao.getRemindersBetween(start, end)
    }

    suspend fun getAll(): List<Reminder> = reminderDao.getAll()

    suspend fun upsert(reminder: Reminder): Long = reminderDao.upsert(reminder)

    suspend fun update(reminder: Reminder) = reminderDao.update(reminder)

    suspend fun completeReminder(reminder: Reminder) {
        val updated = reminder.copy(isCompleted = true, completedAt = System.currentTimeMillis())
        reminderDao.update(updated)

        // Bootstrap stats for first-time users instead of silently returning
        val stats = statsRepository.getLatest() ?: statsRepository.createDefaultStats()

        // Streak increments only once per calendar day, not per task completion
        val todayStart = java.util.Calendar.getInstance().apply {
            set(java.util.Calendar.HOUR_OF_DAY, 0)
            set(java.util.Calendar.MINUTE, 0)
            set(java.util.Calendar.SECOND, 0)
            set(java.util.Calendar.MILLISECOND, 0)
        }.timeInMillis
        val newStreak = if (stats.lastCompletedDate < todayStart) {
            stats.currentStreak + 1
        } else {
            stats.currentStreak
        }

        statsRepository.upsert(stats.copy(
            totalCompleted = stats.totalCompleted + 1,
            currentStreak = newStreak,
            longestStreak = maxOf(stats.longestStreak, newStreak),
            lastCompletedDate = System.currentTimeMillis()
        ))
    }

    suspend fun delete(reminder: Reminder) = reminderDao.delete(reminder)

    suspend fun updateProcrastinationScore(reminderId: Long, score: Float) {
        reminderDao.updateProcrastinationScore(reminderId, score)
    }
}
