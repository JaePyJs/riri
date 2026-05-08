package com.riri.app.ui.screens.profile

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.riri.app.data.repository.ReminderRepository
import com.riri.app.data.repository.StatsRepository
import com.riri.app.data.db.entities.UserStats
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class ProfileUiState(
    val userName: String = "Alex",
    val streakCount: Int = 7,
    val completionRate: Int = 0,
    val totalDone: Int = 0,
    val bestStreak: Int = 0,
    val currentTitle: String = "Productive-ish Era",
    val bondProgress: Float = 0.45f,
    val isLoading: Boolean = true
)

class ProfileViewModel(
    private val reminderRepository: ReminderRepository,
    private val statsRepository: StatsRepository,
    private val userPreferencesDataStore: com.riri.app.data.preferences.UserPreferencesDataStore,
    private val buildShareCardUseCase: com.riri.app.domain.usecase.BuildShareCardUseCase,
    private val shareService: com.riri.app.core.utils.ShareService
) : ViewModel() {
    
    fun shareProfile() {
        viewModelScope.launch {
            val result = buildShareCardUseCase.execute()
            result.getOrNull()?.let { bitmap ->
                shareService.shareImage(bitmap, "Check out my Riri progress! 🔥")
            }
        }
    }

    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    init {
        loadStats()
        observeName()
    }

    private fun observeName() {
        viewModelScope.launch {
            userPreferencesDataStore.userName.collect { name ->
                _uiState.update { it.copy(userName = name) }
            }
        }
    }

    private fun loadStats() {
        viewModelScope.launch {
            reminderRepository.observeReminders()
                .combine(statsRepository.observeStats()) { reminders, stats ->
                    val totalDone = reminders.count { it.isCompleted }
                    val currentStats = stats.lastOrNull() ?: UserStats(
                        weekStartDate = 0L,
                        weekEndDate = 0L,
                        totalSet = 0,
                        totalCompleted = 0,
                        totalIgnored = 0,
                        totalRescheduled = 0,
                        currentStreak = 0,
                        longestStreak = 0,
                        personalityTitle = "Productive-ish Era",
                        procrastinationScore = 0f
                    )
                    
                    ProfileUiState(
                        completionRate = if (reminders.isNotEmpty()) (totalDone * 100 / reminders.size) else 0,
                        totalDone = totalDone,
                        streakCount = currentStats.currentStreak,
                        bestStreak = currentStats.longestStreak.coerceAtLeast(12),
                        currentTitle = currentStats.personalityTitle,
                        bondProgress = 0.45f,
                        isLoading = false
                    )
                }.collect { newState ->
                    _uiState.value = newState
                }
        }
    }
}
