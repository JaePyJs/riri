package com.riri.app.core.notifications

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.riri.app.R
import com.riri.app.domain.model.PersonalityMode

class RiriNotificationManager(private val context: Context) {

    companion object {
        private const val CHANNEL_ID = "riri_reminders"
        private const val CHANNEL_NAME = "Riri Reminders"
    }

    init {
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance).apply {
                description = "Notifications for Riri reminders"
            }
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun showReminderNotification(
        id: Long,
        title: String,
        mode: PersonalityMode,
        snoozeCount: Int = 0,
        daysOverdue: Int = 0
    ) {
        val (notifTitle, notifBody) = PersonalityNotificationCopy.getNotificationText(
            mode, title, snoozeCount, daysOverdue
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground) // Replace with Riri icon
            .setContentTitle(notifTitle)
            .setContentText(notifBody)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)

        with(NotificationManagerCompat.from(context)) {
            notify(id.hashCode(), builder.build())
        }
    }
}
