package com.riri.app.data.db.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "user_stats")
data class UserStats(
    @PrimaryKey val weekStartDate: Long,
    val weekEndDate: Long,
    val totalSet: Int,
    val totalCompleted: Int,
    val totalIgnored: Int,
    val totalRescheduled: Int,
    val currentStreak: Int,
    val longestStreak: Int,
    val personalityTitle: String,
    val procrastinationScore: Float,
    val lastCompletedDate: Long = 0L,
    val generatedAt: Long = System.currentTimeMillis()
)
