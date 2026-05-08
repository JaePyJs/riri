package com.riri.app.data.db.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "reminders")
data class Reminder(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val title: String,
    val description: String?,
    val category: String,
    val dueDateTime: Long,
    val isCompleted: Boolean = false,
    val isRecurring: Boolean = false,
    val recurringInterval: String?,
    val recurringRuleJson: String?,
    val snoozeCount: Int = 0,
    val rescheduleCount: Int = 0,
    val createdAt: Long = System.currentTimeMillis(),
    val completedAt: Long? = null,
    val personalityMode: String = "BESTIE",
    val rawInput: String? = null,
    val taglishNormalized: String? = null,
    val taglishTokensJson: String? = null,
    val procrastinationScore: Float = 0f
)
