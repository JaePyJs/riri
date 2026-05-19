package com.riri.app.ui.screens.stats

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.riri.app.data.repository.StatsRepository
import com.riri.app.data.db.entities.UserStats
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.filterNotNull

class StatsViewModel(
    private val statsRepository: StatsRepository
) : ViewModel() {
    
    val stats: StateFlow<UserStats?> = statsRepository.observeStats()
        .map { statsList -> statsList.lastOrNull() }
        .stateIn(
            scope = viewModelScope,
            started = kotlinx.coroutines.flow.SharingStarted.Eagerly,
            initialValue = null
        )
}
