package com.riri.app.workers

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.riri.app.data.db.dao.ReminderDao
import com.riri.app.data.db.dao.UserStatsDao
import com.riri.app.data.db.entities.Reminder
import com.riri.app.data.db.entities.UserStats
import java.time.DayOfWeek
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.temporal.TemporalAdjusters
import kotlin.math.max
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

class ChaosReportWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params), KoinComponent {

    private val reminderDao: ReminderDao by inject()
    private val userStatsDao: UserStatsDao by inject()

    override suspend fun doWork(): Result {
        return try {
            val zone = ZoneId.systemDefault()
            val today = LocalDate.now(zone)
            val weekStartDate = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY))
            val weekEndExclusive = weekStartDate.plusDays(7)
            val weekStartMillis = weekStartDate.atStartOfDay(zone).toInstant().toEpochMilli()
            val weekEndMillis = weekEndExclusive.atStartOfDay(zone).toInstant().toEpochMilli() - 1

            val reminders = reminderDao.getRemindersBetween(weekStartMillis, weekEndMillis)
            val totalSet = reminders.size
            val totalCompleted = reminders.count { it.isCompleted }
            val totalIgnored = reminders.count { !it.isCompleted && it.dueDateTime <= weekEndMillis }
            val totalRescheduled = reminders.sumOf { it.rescheduleCount }
            val procrastinationScore = computeProcrastinationScore(reminders, totalSet, totalIgnored)
            val (currentStreak, longestStreak) = computeStreaks(reminders, weekStartDate, weekEndExclusive, zone)
            val personalityTitle = classifyPersonality(totalSet, totalCompleted, procrastinationScore)

            val stats = UserStats(
                weekStartDate = weekStartMillis,
                weekEndDate = weekEndMillis,
                totalSet = totalSet,
                totalCompleted = totalCompleted,
                totalIgnored = totalIgnored,
                totalRescheduled = totalRescheduled,
                currentStreak = currentStreak,
                longestStreak = longestStreak,
                personalityTitle = personalityTitle,
                procrastinationScore = procrastinationScore,
                generatedAt = Instant.now().toEpochMilli()
            )
            userStatsDao.upsert(stats)
            Result.success()
        } catch (_: Exception) {
            Result.retry()
        }
    }

    private fun computeProcrastinationScore(
        reminders: List<Reminder>,
        totalSet: Int,
        totalIgnored: Int
    ): Float {
        if (totalSet == 0) return 0f
        val avgProcrastination = reminders.map { it.procrastinationScore }.average().toFloat()
        val ignoredFactor = totalIgnored.toFloat() / totalSet.toFloat()
        return (avgProcrastination * 0.7f) + (ignoredFactor * 0.3f)
    }

    private fun computeStreaks(
        reminders: List<Reminder>,
        weekStart: LocalDate,
        weekEndExclusive: LocalDate,
        zone: ZoneId
    ): Pair<Int, Int> {
        val completedDates = reminders.asSequence()
            .filter { it.isCompleted }
            .map { toLocalDate(it, zone) }
            .filter { !it.isBefore(weekStart) && it.isBefore(weekEndExclusive) }
            .toSet()

        var currentStreak = 0
        var cursor = LocalDate.now(zone)
        val lastDay = weekEndExclusive.minusDays(1)
        if (cursor.isAfter(lastDay)) {
            cursor = lastDay
        }
        while (!cursor.isBefore(weekStart) && completedDates.contains(cursor)) {
            currentStreak += 1
            cursor = cursor.minusDays(1)
        }

        var longestStreak = 0
        var rolling = 0
        var day = weekStart
        while (day.isBefore(weekEndExclusive)) {
            if (completedDates.contains(day)) {
                rolling += 1
                longestStreak = max(longestStreak, rolling)
            } else {
                rolling = 0
            }
            day = day.plusDays(1)
        }

        return currentStreak to max(longestStreak, currentStreak)
    }

    private fun toLocalDate(reminder: Reminder, zone: ZoneId): LocalDate {
        val timestamp = reminder.completedAt ?: reminder.dueDateTime
        return Instant.ofEpochMilli(timestamp).atZone(zone).toLocalDate()
    }

    private fun classifyPersonality(totalSet: Int, totalCompleted: Int, procrastinationScore: Float): String {
        if (totalSet == 0) return "Tahimik Week"
        val completionRate = totalCompleted.toFloat() / totalSet.toFloat()
        return when {
            completionRate >= 0.85f && procrastinationScore < 0.3f -> "Solid Bestie"
            completionRate >= 0.6f -> "Trying Pa"
            completionRate >= 0.3f -> "Chaotic Week"
            else -> "Bahala Na"
        }
    }
}
