package com.riri.app.di

import androidx.room.Room
import com.riri.app.core.ai.*
import com.riri.app.core.notifications.RiriNotificationManager
import com.riri.app.core.utils.ShareService
import com.riri.app.data.db.RiriDatabase
import com.riri.app.data.preferences.UserPreferencesDataStore
import com.riri.app.data.repository.*
import com.riri.app.domain.usecase.BuildShareCardUseCase
import com.riri.app.ui.screens.chat.ChatViewModel
import com.riri.app.ui.screens.dashboard.DashboardViewModel
import com.riri.app.ui.screens.profile.ProfileViewModel
import com.riri.app.ui.screens.settings.SettingsViewModel
import org.koin.android.ext.koin.androidContext
import org.koin.androidx.viewmodel.dsl.viewModel
import org.koin.dsl.module

val appModule = module {
    single {
        Room.databaseBuilder(
            androidContext(),
            RiriDatabase::class.java,
            RiriDatabase.DB_NAME
        )
        .fallbackToDestructiveMigration()
        .build()
    }
    single { get<RiriDatabase>().reminderDao() }
    single { get<RiriDatabase>().userStatsDao() }
    single { get<RiriDatabase>().chatDao() }
    
    single { TaglishParser() }
    single { CategoryClassifier(androidContext()) }
    single { TaglishKeywordClassifier() }
    single { WhisperEngine(androidContext()) }
    single { KeywordClassifier() }
    single { OnnxFallbackEngine(androidContext(), get(), get()) }
    single { LocalLLMEngine(androidContext()) }
    single { ModelDownloadManager(androidContext()) }
    single { AIEngineRouter(get(), get(), get()) }
    single { RiriNotificationManager(androidContext()) }
    single { UserPreferencesDataStore(androidContext()) }
    
    single { ReminderRepository(get(), get()) }
    single { StatsRepository(get()) }
    single { ChatRepository(get()) }
    
    factory { BuildShareCardUseCase(androidContext(), get(), get()) }
    single { ShareService(androidContext()) }
    
    viewModel { DashboardViewModel(get(), get(), get(), get()) }
    viewModel { SettingsViewModel(get()) }
    viewModel { ProfileViewModel(get(), get(), get(), get(), get()) }
    viewModel { ChatViewModel(get(), get(), get(), get(), get()) }
    viewModel { com.riri.app.ui.screens.dashboard.AddReminderViewModel(get()) }
    viewModel { com.riri.app.ui.screens.onboarding.OnboardingViewModel(get(), get()) }
}
