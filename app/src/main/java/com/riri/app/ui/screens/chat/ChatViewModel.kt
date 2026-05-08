package com.riri.app.ui.screens.chat

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.riri.app.core.ai.AIEngineRouter
import com.riri.app.core.ai.LocalLLMEngine
import com.riri.app.data.preferences.UserPreferencesDataStore
import com.riri.app.data.repository.ChatRepository
import com.riri.app.domain.model.PersonalityMode
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class ChatUiState(
    val messages: List<com.riri.app.data.db.entities.ChatMessage> = emptyList(),
    val isTyping: Boolean = false,
    val currentPersonality: PersonalityMode = PersonalityMode.BESTIE
)

class ChatViewModel(
    private val chatRepository: ChatRepository,
    private val reminderRepository: com.riri.app.data.repository.ReminderRepository,
    private val aiRouter: AIEngineRouter,
    private val localLLM: LocalLLMEngine,
    private val preferences: UserPreferencesDataStore
) : ViewModel() {

    private val _uiState = MutableStateFlow(ChatUiState())
    val uiState: StateFlow<ChatUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            if (localLLM.isModelReady()) {
                localLLM.load()
            }
        }
        viewModelScope.launch {
            chatRepository.getMessages().collect { messages ->
                _uiState.update { it.copy(messages = messages) }
            }
        }
        
        preferences.personalityMode
            .onEach { mode ->
                _uiState.update { it.copy(currentPersonality = PersonalityMode.valueOf(mode)) }
            }
            .launchIn(viewModelScope)
    }

    fun sendMessage(text: String) {
        if (text.isBlank()) return

        viewModelScope.launch {
            if (!localLLM.isLoaded() && localLLM.isModelReady()) {
                localLLM.load()
            }

            // 1. Save user message
            chatRepository.sendMessage(text, isUser = true)
            _uiState.update { it.copy(isTyping = true) }

            // 2. Check reminder intent BEFORE going to LLM
            if (isReminderIntent(text)) {
                // Try to parse and save the reminder
                val saved = tryCreateReminderFromChat(text)
                val confirmationMsg = if (saved != null) {
                    val personality = _uiState.value.currentPersonality
                    when (personality) {
                        PersonalityMode.BESTIE -> "Sige bestie! Naka-set na ang reminder: \"${saved.title}\" ✅ I'll bug you on time!"
                        PersonalityMode.MALUPIT -> "Done. \"${saved.title}\" — set na. Wag mong kalimutan."
                        PersonalityMode.CHILL -> "Okay lang~ naka-save na: \"${saved.title}\" 🌙 I gotchu."
                        PersonalityMode.TITA -> "Hala anak, naka-save na! \"${saved.title}\" — hindi ka namin pababayaan ✨"
                    }
                } else {
                    "Hmm, di ko ma-parse ng maayos yung reminder mo. Try mo: \"Remind me to [task] at [time]\" para mas klaro! 📝"
                }
                chatRepository.sendMessage(confirmationMsg, isUser = false)
                _uiState.update { it.copy(isTyping = false) }
                return@launch  // Don't fall through to LLM
            }

            // 3. Non-reminder message — send to LLM or Lite fallback
            val personality = _uiState.value.currentPersonality
            val prompt = buildPrompt(text, personality)
            var responseBuffer = ""

            localLLM.generateResponse(
                prompt = prompt,
                onToken = { token -> responseBuffer += token },
                onComplete = {
                    viewModelScope.launch {
                        val finalResponse = if (responseBuffer.isBlank()) {
                            generateLiteResponse(text)
                        } else {
                            responseBuffer.stripModelTokens()
                        }
                        chatRepository.sendMessage(finalResponse, isUser = false)
                        _uiState.update { it.copy(isTyping = false) }
                    }
                }
            )
        }
    }

    private fun generateLiteResponse(input: String): String {
        return when {
            input.contains("hello", true) || input.contains("hi", true) -> "Hoy! Bestie here. Naka-Lite Mode ako ngayon kasi hindi pa downloaded brain ko, pero I can still help you with reminders! ✨"
            input.contains("remind", true) || input.contains("task", true) -> "Type mo lang yung task details (e.g. 'Remind me to drink water at 3pm') tapos ako na bahala mag-save! 📝"
            else -> "Narinig kita! Pero naka-Lite Mode lang ako. I-download mo full brain ko sa settings para mas matalino ako. Pero for now, focus muna tayo sa tasks! 💪"
        }
    }

    private fun buildPrompt(userMessage: String, mode: PersonalityMode): String {
        val system = when (mode) {
            PersonalityMode.BESTIE -> "You are Riri, a chill but sharp reminder assistant for Filipino Gen Z. Speak Taglish. Max 3 sentences. Never robotic."
            PersonalityMode.MALUPIT -> "You are Riri in MALUPIT mode. Blunt, no-nonsense, slightly intense pero helpful. Mostly English, short. Max 2 sentences."
            PersonalityMode.CHILL -> "You are Riri in CHILL mode. Relaxed, no pressure, supportive. Taglish, soft tone. Max 3 sentences."
            PersonalityMode.TITA -> "You are Riri in TITA mode. Loving Filipino aunt energy. Uses 'anak'. Taglish with more Tagalog. Max 3 sentences."
        }
        return "<|im_start|>system\n$system<|im_end|>\n<|im_start|>user\n$userMessage<|im_end|>\n<|im_start|>assistant\n"
    }

    private fun isReminderIntent(input: String): Boolean {
        val lower = input.lowercase()
        val reminderKeywords = listOf(
            // English
            "remind", "reminder", "wake me", "wake me up", "alarm", "schedule",
            "set a", "don't forget", "dont forget", "remember to", "notify me",
            "alert me", "at ", "by ", "tomorrow", "tonight", "later",
            // Taglish / Tagalog
            "paalala", "pa-remind", "ipaalala", "tandaan", "i-schedule",
            "bukas", "mamaya", "mamayang", "ngayong gabi", "sa umaga",
            "ng umaga", "ng hapon", "ng gabi", "am", "pm"
        )
        return reminderKeywords.any { lower.contains(it) }
    }

    private suspend fun tryCreateReminderFromChat(input: String): com.riri.app.data.db.entities.Reminder? {
        return try {
            val taglishParser = com.riri.app.core.ai.TaglishParser()
            val parsed = taglishParser.parse(input)
            val category = aiRouter.categorizeReminder(input)

            val reminder = com.riri.app.data.db.entities.Reminder(
                title = parsed.title,
                description = "Added via chat: \"$input\"",
                category = category.name,
                dueDateTime = parsed.dueDateTime,
                isRecurring = parsed.isRecurring,
                recurringInterval = parsed.recurringInterval,
                recurringRuleJson = null,
                rawInput = input
            )
            reminderRepository.upsert(reminder)
            reminder
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    fun clearHistory() {
        viewModelScope.launch {
            chatRepository.clearHistory()
        }
    }
}

fun String.stripModelTokens(): String = this
    .replace("<|im_end|>", "")
    .replace("<|im_start|>", "")
    .replace("<|end|>", "")
    .replace("</s>", "")
    .replace("[/INST]", "")
    .replace("<|eot_id|>", "")
    .trim()
