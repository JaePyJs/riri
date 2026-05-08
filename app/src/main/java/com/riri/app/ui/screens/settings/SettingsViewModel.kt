package com.riri.app.ui.screens.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.riri.app.data.preferences.UserPreferencesDataStore
import com.riri.app.domain.model.PersonalityMode
import com.riri.app.core.ai.ModelDownloadManager
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class SettingsUiState(
    val personalityMode: PersonalityMode = PersonalityMode.BESTIE,
    val notificationsEnabled: Boolean = true,
    val userName: String = ""
)

class SettingsViewModel(
    private val preferences: UserPreferencesDataStore,
    private val modelDownloadManager: ModelDownloadManager
) : ViewModel() {

    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    val downloadProgress: StateFlow<Float> = modelDownloadManager.downloadProgress
    val isModelDownloaded: Boolean
        get() = modelDownloadManager.isDownloaded

    private val _isDownloading = MutableStateFlow(false)
    val isDownloading: StateFlow<Boolean> = _isDownloading.asStateFlow()

    init {
        preferences.personalityMode
            .onEach { modeStr ->
                _uiState.update { it.copy(personalityMode = PersonalityMode.valueOf(modeStr)) }
            }
            .launchIn(viewModelScope)

        preferences.notificationsEnabled
            .onEach { enabled ->
                _uiState.update { it.copy(notificationsEnabled = enabled) }
            }
            .launchIn(viewModelScope)

        preferences.userName
            .onEach { name ->
                _uiState.update { it.copy(userName = name) }
            }
            .launchIn(viewModelScope)
    }

    fun setPersonalityMode(mode: PersonalityMode) {
        viewModelScope.launch {
            preferences.setPersonalityMode(mode.name)
        }
    }

    fun toggleNotifications(enabled: Boolean) {
        viewModelScope.launch {
            preferences.setNotificationsEnabled(enabled)
        }
    }

    fun updateName(newName: String) {
        viewModelScope.launch {
            preferences.setUserName(newName)
        }
    }

    fun startModelDownload() {
        if (_isDownloading.value) return
        _isDownloading.value = true
        viewModelScope.launch {
            try {
                modelDownloadManager.downloadModel()
            } catch (e: Exception) {
                e.printStackTrace()
                _isDownloading.value = false
            }
        }
    }
}
