package com.riri.app.data.preferences

import android.content.Context
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore by preferencesDataStore(name = "riri_prefs")

class UserPreferencesDataStore(private val context: Context) {
    val personalityMode: Flow<String> = context.dataStore.data.map { prefs ->
        prefs[Keys.PERSONALITY_MODE] ?: "BESTIE"
    }

    val userName: Flow<String> = context.dataStore.data.map { prefs ->
        prefs[Keys.USER_NAME] ?: "Laban"
    }

    val notificationsEnabled: Flow<Boolean> = context.dataStore.data.map { prefs ->
        prefs[Keys.NOTIFICATIONS_ENABLED] ?: true
    }

    val lastChaosReportMillis: Flow<Long> = context.dataStore.data.map { prefs ->
        prefs[Keys.LAST_CHAOS_REPORT] ?: 0L
    }

    val hasCompletedOnboarding: Flow<Boolean> = context.dataStore.data.map { prefs ->
        prefs[Keys.HAS_COMPLETED_ONBOARDING] ?: false
    }

    suspend fun setPersonalityMode(mode: String) {
        context.dataStore.edit { prefs ->
            prefs[Keys.PERSONALITY_MODE] = mode
        }
    }

    suspend fun setUserName(name: String) {
        context.dataStore.edit { prefs ->
            prefs[Keys.USER_NAME] = name
        }
    }

    suspend fun setNotificationsEnabled(enabled: Boolean) {
        context.dataStore.edit { prefs ->
            prefs[Keys.NOTIFICATIONS_ENABLED] = enabled
        }
    }

    suspend fun setLastChaosReportMillis(timestamp: Long) {
        context.dataStore.edit { prefs ->
            prefs[Keys.LAST_CHAOS_REPORT] = timestamp
        }
    }

    suspend fun setOnboardingCompleted() {
        context.dataStore.edit { prefs ->
            prefs[Keys.HAS_COMPLETED_ONBOARDING] = true
        }
    }

    private object Keys {
        val PERSONALITY_MODE = stringPreferencesKey("personality_mode")
        val USER_NAME = stringPreferencesKey("user_name")
        val NOTIFICATIONS_ENABLED = booleanPreferencesKey("notifications_enabled")
        val LAST_CHAOS_REPORT = longPreferencesKey("last_chaos_report")
        val HAS_COMPLETED_ONBOARDING = booleanPreferencesKey("has_completed_onboarding")
    }
}
