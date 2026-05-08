package com.riri.app.core.notifications

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.riri.app.R
import com.riri.app.data.preferences.UserPreferencesDataStore
import com.riri.app.domain.model.PersonalityMode
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

class ReminderAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra(EXTRA_REMINDER_TITLE) ?: return
        val reminderId = intent.getLongExtra(EXTRA_REMINDER_ID, 0L)
        val modeExtra = intent.getStringExtra(EXTRA_PERSONALITY_MODE)

        val pendingResult = goAsync()
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val preferences = UserPreferencesDataStore(context)
                val notificationsEnabled = preferences.notificationsEnabled.first()
                if (!notificationsEnabled) return@launch

                val mode = runCatching { modeExtra?.let { PersonalityMode.valueOf(it) } }
                    .getOrNull()
                    ?: runBlocking {
                        // BroadcastReceiver requires synchronous fallback when extras are missing.
                        val fallback = preferences.personalityMode.first()
                        runCatching { PersonalityMode.valueOf(fallback) }
                            .getOrDefault(PersonalityMode.BESTIE)
                    }

                RiriNotificationManager(context).showReminderNotification(
                    id = reminderId,
                    title = title,
                    mode = mode
                )
            } finally {
                pendingResult.finish()
            }
        }
    }

    companion object {
        const val EXTRA_REMINDER_ID = "extra_reminder_id"
        const val EXTRA_REMINDER_TITLE = "extra_reminder_title"
        const val EXTRA_PERSONALITY_MODE = "personality_mode"
    }
}
