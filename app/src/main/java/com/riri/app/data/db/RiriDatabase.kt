package com.riri.app.data.db

import androidx.room.Database
import androidx.room.RoomDatabase
import com.riri.app.data.db.dao.*
import com.riri.app.data.db.entities.*

@Database(
    entities = [Reminder::class, UserStats::class, ChatMessage::class],
    version = 2,
    exportSchema = false
)
abstract class RiriDatabase : RoomDatabase() {
    abstract fun reminderDao(): ReminderDao
    abstract fun userStatsDao(): UserStatsDao
    abstract fun chatDao(): ChatDao

    companion object {
        const val DB_NAME = "riri.db"
    }
}
