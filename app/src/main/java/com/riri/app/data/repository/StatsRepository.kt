package com.riri.app.data.repository

import com.riri.app.data.db.dao.UserStatsDao
import com.riri.app.data.db.entities.UserStats

class StatsRepository(private val userStatsDao: UserStatsDao) {
    suspend fun getWeek(weekStartDate: Long): UserStats? = userStatsDao.getWeek(weekStartDate)

    suspend fun getLatest(): UserStats? = userStatsDao.getLatest()

    suspend fun upsert(stats: UserStats) = userStatsDao.upsert(stats)

    fun observeStats(): kotlinx.coroutines.flow.Flow<List<UserStats>> = userStatsDao.getAll()
}
