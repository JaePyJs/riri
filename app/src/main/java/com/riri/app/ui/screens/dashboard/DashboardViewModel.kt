package com.riri.app.ui.screens.dashboard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.riri.app.data.repository.ReminderRepository
import com.riri.app.ui.components.DashboardState
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class DashboardViewModel(
    private val reminderRepository: ReminderRepository,
    private val taglishParser: com.riri.app.core.ai.TaglishParser,
    private val aiRouter: com.riri.app.core.ai.AIEngineRouter,
    private val userPreferencesDataStore: com.riri.app.data.preferences.UserPreferencesDataStore
) : ViewModel() {

    private val _uiState = MutableStateFlow(DashboardUiState())
    val uiState: StateFlow<DashboardUiState> = _uiState.asStateFlow()

    init {
        observeReminders()
        observeName()
    }

    private fun observeName() {
        viewModelScope.launch {
            userPreferencesDataStore.userName.collect { name ->
                _uiState.update { it.copy(userName = name) }
            }
        }
    }

    fun addReminder(input: String, manualDueDateTime: Long? = null) {
        viewModelScope.launch {
            val parsed = taglishParser.parse(input)
            val category = aiRouter.categorizeReminder(input)
            
            val reminder = com.riri.app.data.db.entities.Reminder(
                title = parsed.title,
                description = null,
                category = category.name,
                dueDateTime = manualDueDateTime ?: parsed.dueDateTime,
                isRecurring = parsed.isRecurring,
                recurringInterval = parsed.recurringInterval,
                recurringRuleJson = null,
                rawInput = input
            )
            
            reminderRepository.upsert(reminder)
        }
    }

    fun toggleReminderCompletion(reminder: com.riri.app.data.db.entities.Reminder) {
        viewModelScope.launch {
            if (reminder.isCompleted) {
                reminderRepository.update(reminder.copy(isCompleted = false, completedAt = null))
            } else {
                reminderRepository.completeReminder(reminder)
            }
        }
    }

    fun deleteReminder(reminder: com.riri.app.data.db.entities.Reminder) {
        viewModelScope.launch {
            reminderRepository.delete(reminder)
        }
    }

    private fun observeReminders() {
        viewModelScope.launch {
            reminderRepository.observeReminders().collect { reminders ->
                val characterState = when {
                    reminders.isEmpty() -> DashboardState.EMPTY
                    reminders.any { !it.isCompleted && it.dueDateTime < System.currentTimeMillis() } -> DashboardState.OVERDUE
                    else -> DashboardState.READY
                }
                
                _uiState.update { 
                    it.copy(
                        reminders = reminders,
                        characterState = characterState
                    )
                }
            }
        }
    }
}
