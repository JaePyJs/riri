package com.riri.app.domain.usecase

data class ShareCardData(
    val personalityTitle: String,
    val streakCount: Int,
    val totalDone: Int,
    val completionRate: Int
)
