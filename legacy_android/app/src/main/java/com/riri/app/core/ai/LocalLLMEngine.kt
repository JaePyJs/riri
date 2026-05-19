package com.riri.app.core.ai

import android.content.Context
import com.riri.app.domain.model.PersonalityMode
import com.riri.app.domain.model.ReminderCategory
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

class LocalLLMEngine(private val context: Context) {
    private var llmInference: LlmInference? = null

    suspend fun load() {
        if (llmInference != null) return
        val modelFile = File(context.filesDir, MODEL_FILE_NAME)
        if (!modelFile.exists()) return

        val options = LlmInference.LlmInferenceOptions.builder()
            .setModelPath(modelFile.absolutePath)
            .setMaxTokens(512)
            .build()

        llmInference = withContext(Dispatchers.IO) {
            LlmInference.createFromOptions(context, options)
        }
    }

    fun isModelReady(): Boolean {
        val modelFile = File(context.filesDir, MODEL_FILE_NAME)
        return modelFile.exists()
    }

    fun isLoaded(): Boolean {
        return llmInference != null
    }

    fun generateResponse(
        prompt: String,
        onToken: (String) -> Unit,
        onComplete: () -> Unit
    ) {
        val inference = llmInference
        if (inference == null) {
            onComplete()
            return
        }
        
        try {
            inference.generateResponseAsync(prompt) { partialResult, done ->
                if (partialResult.isNotEmpty()) {
                    // Clean tokens like <|im_end|> from streaming result
                    val cleanToken = partialResult
                        .replace("<|im_end|>", "")
                        .replace("<|im_start|>", "")
                        .replace("<|endoftext|>", "")
                    if (cleanToken.isNotEmpty()) onToken(cleanToken)
                }
                if (done) {
                    onComplete()
                }
            }
        } catch (e: Exception) {
            onComplete()
        }
    }

    suspend fun categorizeReminder(
        input: String,
        rescheduleCount: Int? = null
    ): ReminderCategory {
        if ((rescheduleCount ?: 0) >= 3) return ReminderCategory.BAHALA_NA
        val inference = llmInference ?: return ReminderCategory.PERSONAL

        val prompt = buildPrompt(
            "Categorize this reminder into one of: SCHOOL, WORK, HEALTH, SOCIAL, ERRANDS, PERSONAL, BAHALA_NA. Input: $input. Reply only with the category.",
            PersonalityMode.BESTIE
        )

        val response = runCatching {
            generateSingleResponse(inference, prompt)
        }.getOrNull().orEmpty()

        val cleaned = response.trim().uppercase()
        return runCatching { ReminderCategory.valueOf(cleaned) }
            .getOrDefault(ReminderCategory.PERSONAL)
    }

    fun release() {
        llmInference?.close()
        llmInference = null
    }

    private suspend fun generateSingleResponse(
        inference: LlmInference,
        prompt: String
    ): String = withContext(Dispatchers.IO) {
        inference.generateResponse(prompt)
    }
}

fun buildPrompt(userMessage: String, mode: PersonalityMode): String {
    val system = when (mode) {
        PersonalityMode.BESTIE -> "You are Riri, a chill but sharp reminder assistant for Filipino Gen Z. Speak Taglish. Max 3 sentences. Never robotic."
        PersonalityMode.MALUPIT -> "You are Riri in MALUPIT mode. Blunt, no-nonsense, slightly intense pero helpful. Mostly English, short. Max 2 sentences."
        PersonalityMode.CHILL -> "You are Riri in CHILL mode. Relaxed, no pressure, supportive. Taglish, soft tone. Max 3 sentences."
        PersonalityMode.TITA -> "You are Riri in TITA mode. Loving Filipino aunt energy. Uses 'anak'. Taglish with more Tagalog. Max 3 sentences."
    }
    return "<|im_start|>system\n$system<|im_end|>\n<|im_start|>user\n$userMessage<|im_end|>\n<|im_start|>assistant\n"
}

private const val MODEL_FILE_NAME = "riri_model.task"
