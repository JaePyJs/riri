package com.riri.app.workers

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.riri.app.core.notifications.NotificationScheduler
import com.riri.app.data.db.dao.ReminderDao
import java.time.Instant
import java.time.temporal.ChronoUnit
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject
import kotlinx.coroutines.flow.first

class ReminderWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params), KoinComponent {

    private val reminderDao: ReminderDao by inject()
    private val preferences: com.riri.app.data.preferences.UserPreferencesDataStore by inject()

    override suspend fun doWork(): Result {
        val now = Instant.now().toEpochMilli()
        val windowEnd = Instant.now().plus(24, ChronoUnit.HOURS).toEpochMilli()
        val reminders = reminderDao.getRemindersBetween(now, windowEnd)
        val mode = preferences.personalityMode.first()

        reminders.forEach { reminder ->
            if (!reminder.isCompleted) {
                NotificationScheduler.scheduleExactReminder(
                    applicationContext,
                    reminder.id,
                    reminder.title,
                    reminder.dueDateTime,
                    mode
                )
            }
        }

        return Result.success()
    }
}
