package com.riri.app.data.db

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.riri.app.data.db.dao.*
import com.riri.app.data.db.entities.*

@Database(
    entities = [Reminder::class, UserStats::class, ChatMessage::class],
    version = 3,
    exportSchema = false
)
abstract class RiriDatabase : RoomDatabase() {
    abstract fun reminderDao(): ReminderDao
    abstract fun userStatsDao(): UserStatsDao
    abstract fun chatDao(): ChatDao

    companion object {
        const val DB_NAME = "riri.db"

        val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE reminders ADD COLUMN taglishNormalized TEXT")
                database.execSQL("ALTER TABLE reminders ADD COLUMN taglishTokensJson TEXT")
                database.execSQL("ALTER TABLE reminders ADD COLUMN procrastinationScore REAL NOT NULL DEFAULT 0")
            }
        }

        val MIGRATION_2_3 = object : Migration(2, 3) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // UserStats: add lastCompletedDate for correct per-day streak tracking
                database.execSQL("ALTER TABLE user_stats ADD COLUMN lastCompletedDate INTEGER NOT NULL DEFAULT 0")
                // ChatMessage: widen id from INTEGER to LONG (SQLite stores as INTEGER, no-op but ensures consistency)
            }
        }
    }
}
