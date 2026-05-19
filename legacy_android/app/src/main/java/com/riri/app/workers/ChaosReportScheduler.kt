package com.riri.app.workers

import android.content.Context
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.time.DayOfWeek
import java.time.Duration
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId
import java.time.temporal.TemporalAdjusters
import java.util.concurrent.TimeUnit

object ChaosReportScheduler {
    private const val UNIQUE_WORK_NAME = "weekly_chaos_report"

    fun scheduleWeekly(context: Context) {
        val initialDelay = computeInitialDelayMillis()
        val request = PeriodicWorkRequestBuilder<ChaosReportWorker>(7, TimeUnit.DAYS)
            .setInitialDelay(initialDelay, TimeUnit.MILLISECONDS)
            .build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            UNIQUE_WORK_NAME,
            ExistingPeriodicWorkPolicy.UPDATE,
            request
        )
    }

    private fun computeInitialDelayMillis(): Long {
        val zone = ZoneId.systemDefault()
        val now = LocalDateTime.now(zone)
        val nextMonday = LocalDate.now(zone).with(TemporalAdjusters.nextOrSame(DayOfWeek.MONDAY))
        val target = LocalDateTime.of(nextMonday, LocalTime.of(0, 5))
        val adjusted = if (target.isAfter(now)) target else target.plusWeeks(1)
        return Duration.between(now, adjusted).toMillis().coerceAtLeast(0)
    }
}
