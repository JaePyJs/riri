package com.riri.app.workers

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.riri.app.data.db.dao.ReminderDao
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

class PatternAnalysisWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params), KoinComponent {

    private val reminderDao: ReminderDao by inject()

    override suspend fun doWork(): Result {
        val reminders = reminderDao.getAll()
        reminders.forEach { reminder ->
            val score = computeScore(reminder.rescheduleCount, reminder.snoozeCount)
            reminderDao.updateProcrastinationScore(reminder.id, score)
        }
        return Result.success()
    }

    private fun computeScore(rescheduleCount: Int, snoozeCount: Int): Float {
        return when {
            rescheduleCount >= 3 -> 1.0f
            snoozeCount >= 5 -> 0.8f
            rescheduleCount >= 1 -> 0.5f
            else -> 0.0f
        }
    }
}
