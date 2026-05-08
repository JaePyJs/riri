package com.riri.app.domain.usecase

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import com.riri.app.R
import com.riri.app.data.db.entities.UserStats
import com.riri.app.data.repository.ReminderRepository
import com.riri.app.data.repository.StatsRepository
import kotlinx.coroutines.flow.first

class BuildShareCardUseCase(
    private val context: Context,
    private val reminderRepository: ReminderRepository,
    private val statsRepository: StatsRepository
) {
    suspend fun execute(): Result<Bitmap> = runCatching {
        val reminders = reminderRepository.observeReminders().first()
        val stats = statsRepository.observeStats().first().lastOrNull() ?: UserStats(
            weekStartDate = 0L,
            weekEndDate = 0L,
            totalSet = 0,
            totalCompleted = 0,
            totalIgnored = 0,
            totalRescheduled = 0,
            currentStreak = 0,
            longestStreak = 0,
            personalityTitle = "Productive-ish Era",
            procrastinationScore = 0f
        )

        val totalDone = reminders.count { it.isCompleted }
        val rate = if (reminders.isNotEmpty()) (totalDone * 100 / reminders.size) else 0

        val width = 1080
        val height = 1920
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        paint.color = Color.parseColor("#1A1A2E")
        canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)

        paint.color = Color.WHITE
        paint.textSize = 72f
        paint.typeface = Typeface.DEFAULT_BOLD
        canvas.drawText("Weekly Receipts", 80f, 220f, paint)

        paint.textSize = 44f
        paint.typeface = Typeface.DEFAULT
        canvas.drawText("${stats.personalityTitle}", 80f, 320f, paint)

        paint.textSize = 56f
        paint.typeface = Typeface.DEFAULT_BOLD
        canvas.drawText("Streak: ${stats.currentStreak} days", 80f, 460f, paint)

        paint.textSize = 46f
        paint.typeface = Typeface.DEFAULT
        canvas.drawText("Done: $totalDone", 80f, 560f, paint)
        canvas.drawText("Completion: $rate%", 80f, 640f, paint)

        val badge = BitmapFactory.decodeResource(context.resources, R.drawable.streak_celebration)
        canvas.drawBitmap(badge, 640f, 420f, null)

        bitmap
    }
}
