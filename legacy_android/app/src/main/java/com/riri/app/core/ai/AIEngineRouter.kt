package com.riri.app.core.ai

import com.riri.app.domain.model.ReminderCategory

enum class ProcrastinationLevel {
    NONE, MEDIUM, HIGH, BAHALA_NA
}

class AIEngineRouter(
    private val localLLM: LocalLLMEngine,
    private val onnx: OnnxFallbackEngine,
    private val keyword: KeywordClassifier
) {
    suspend fun categorizeReminder(input: String): ReminderCategory {
        return when {
            localLLM.isLoaded() -> localLLM.categorizeReminder(input)
            onnx.isModelAvailable() -> onnx.categorize(input)
            else -> keyword.classify(input)
        }
    }

    suspend fun analyzeProcrastination(rescheduleCount: Int, snoozeCount: Int): ProcrastinationLevel {
        // High-level analysis routing
        return when {
            rescheduleCount + snoozeCount >= 5 -> ProcrastinationLevel.BAHALA_NA
            rescheduleCount >= 3 -> ProcrastinationLevel.HIGH
            rescheduleCount >= 1 -> ProcrastinationLevel.MEDIUM
            else -> ProcrastinationLevel.NONE
        }
    }

    fun currentEngineLabel(): String {
        return when {
            localLLM.isLoaded() -> "Local LLM"
            onnx.isModelAvailable() -> "ONNX"
            else -> "Keyword"
        }
    }
}

