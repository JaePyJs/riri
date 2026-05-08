package com.riri.app.ui.screens.onboarding

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.riri.app.core.ai.ModelDownloadManager
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class OnboardingViewModel(
    private val modelDownloadManager: ModelDownloadManager,
    private val userPreferencesDataStore: com.riri.app.data.preferences.UserPreferencesDataStore
) : ViewModel() {

    val downloadProgress: StateFlow<Float> = modelDownloadManager.downloadProgress
    val isModelDownloaded: Boolean
        get() = modelDownloadManager.isDownloaded

    private val _isDownloading = kotlinx.coroutines.flow.MutableStateFlow(false)
    val isDownloading: StateFlow<Boolean> = _isDownloading.asStateFlow()

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

    fun saveName(name: String) {
        viewModelScope.launch {
            userPreferencesDataStore.setUserName(name)
        }
    }
}
