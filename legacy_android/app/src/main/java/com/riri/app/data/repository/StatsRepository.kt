package com.riri.app.data.repository

import com.riri.app.data.db.dao.UserStatsDao
import com.riri.app.data.db.entities.UserStats

class StatsRepository(private val userStatsDao: UserStatsDao) {
    suspend fun getWeek(weekStartDate: Long): UserStats? = userStatsDao.getWeek(weekStartDate)

    suspend fun getLatest(): UserStats? = userStatsDao.getLatest()

    suspend fun upsert(stats: UserStats) = userStatsDao.upsert(stats)

    fun observeStats(): kotlinx.coroutines.flow.Flow<List<UserStats>> = userStatsDao.getAll()

    suspend fun createDefaultStats(): UserStats {
        val now = System.currentTimeMillis()
        val default = UserStats(
            weekStartDate = now,
            weekEndDate = now + (7 * 24 * 60 * 60 * 1000L),
            totalSet = 0,
            totalCompleted = 0,
            totalIgnored = 0,
            totalRescheduled = 0,
            currentStreak = 0,
            longestStreak = 0,
            personalityTitle = "Just Getting Started",
            procrastinationScore = 0f,
            lastCompletedDate = 0L
        )
        userStatsDao.upsert(default)
        return default
    }
}
