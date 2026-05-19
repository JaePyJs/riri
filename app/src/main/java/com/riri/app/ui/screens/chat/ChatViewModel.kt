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
    private val preferences: UserPreferencesDataStore,
    private val intentClassifier: com.riri.app.core.ai.IntentClassifier,
    private val chatSession: com.riri.app.core.ai.ChatSession
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

            // 2. Handle Pending Clarification
            if (chatSession.pendingReminder != null) {
                val reminder = chatSession.pendingReminder!!.copy(title = text)
                reminderRepository.upsert(reminder)
                chatSession.clear()
                
                val confirmation = getClarificationConfirmation(reminder.title)
                chatRepository.sendMessage(confirmation, isUser = false)
                _uiState.update { it.copy(isTyping = false) }
                return@launch
            }

            // 3. Classify Intent
            val intent = intentClassifier.classify(text)
            
            if (intent == com.riri.app.core.ai.RiriIntent.REMINDER) {
                val parser = com.riri.app.core.ai.TaglishParser()
                val parsed = parser.parse(text)
                
                if (parser.isValid(parsed)) {
                    val category = aiRouter.categorizeReminder(text)
                    val reminder = com.riri.app.data.db.entities.Reminder(
                        title = parsed.title,
                        description = "Added via chat: \"$text\"",
                        category = category.name,
                        dueDateTime = parsed.dueDateTime,
                        recurringInterval = null,
                        recurringRuleJson = null,
                        rawInput = text
                    )
                    reminderRepository.upsert(reminder)
                    
                    val msg = getReminderConfirmation(reminder.title)
                    chatRepository.sendMessage(msg, isUser = false)
                } else {
                    // Ambiguous/Incomplete reminder
                    val category = aiRouter.categorizeReminder(text)
                    chatSession.pendingReminder = com.riri.app.data.db.entities.Reminder(
                        title = "", // Missing
                        description = "Pending clarification for: \"$text\"",
                        category = category.name,
                        dueDateTime = parsed.dueDateTime,
                        recurringInterval = null,
                        recurringRuleJson = null,
                        rawInput = text
                    )
                    val msg = getClarificationRequest()
                    chatRepository.sendMessage(msg, isUser = false)
                }
                _uiState.update { it.copy(isTyping = false) }
                return@launch
            }

            // 4. General Chat (LLM or Lite)
            val personality = _uiState.value.currentPersonality
            val prompt = buildPrompt(text, personality)
            var responseBuffer = ""

            localLLM.generateResponse(
                prompt = prompt,
                onToken = { token -> responseBuffer += token },
                onComplete = {
                    viewModelScope.launch {
                        val finalResponse = if (responseBuffer.isBlank()) {
                            generateLiteResponse(text, personality)
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

    private fun getReminderConfirmation(title: String): String {
        return when (_uiState.value.currentPersonality) {
            PersonalityMode.BESTIE -> "Sige bestie! Naka-set na: \"$title\" ✅ I gotchu!"
            PersonalityMode.MALUPIT -> "Done. \"$title\" is set. Don't fail me."
            PersonalityMode.CHILL -> "Okay lang~ naka-save na: \"$title\" 🌙 Relax ka lang."
            PersonalityMode.TITA -> "Hala anak, naka-set na! \"$title\" — wag mong kalimutan ha? ✨"
        }
    }

    private fun getClarificationRequest(): String {
        return when (_uiState.value.currentPersonality) {
            PersonalityMode.BESTIE -> "Ay wait, anong exact task yan bestie? Para ma-save ko ng maayos! 📝"
            PersonalityMode.MALUPIT -> "Kulang yung info. Anong task yan? Be specific."
            PersonalityMode.CHILL -> "Wait lang~ ano palang gagawin natin? 🌙"
            PersonalityMode.TITA -> "Hala anak, ano palang ipapaalala ko sayo? Para malista ko na. ✨"
        }
    }

    private fun getClarificationConfirmation(title: String): String {
        return when (_uiState.value.currentPersonality) {
            PersonalityMode.BESTIE -> "Ayun! \"$title\" — naka-save na bestie! ✨"
            PersonalityMode.MALUPIT -> "Copy. \"$title\" set na."
            PersonalityMode.CHILL -> "Geh, \"$title\" na yan. 🌙"
            PersonalityMode.TITA -> "Salamat anak! \"$title\" — naka-lista na ha. ✨"
        }
    }

    private fun generateLiteResponse(input: String, mode: PersonalityMode): String {
        val lower = input.lowercase()
        return when (mode) {
            PersonalityMode.BESTIE -> when {
                lower.contains("hi") || lower.contains("hello") -> "Hoy bestie! Laban tayo today! ✨"
                lower.contains("salamat") || lower.contains("thanks") -> "No biggie! You're doing great! 💜"
                else -> "Narinig kita! Pero focus muna tayo sa goals natin today ha? 💪"
            }
            PersonalityMode.MALUPIT -> when {
                lower.contains("hi") || lower.contains("hello") -> "Focus. May gagawin ka pa."
                lower.contains("salamat") || lower.contains("thanks") -> "Gawin mo na lang yung task."
                else -> "Whatever. Just finish your reminders."
            }
            PersonalityMode.CHILL -> "Relax lang tayo~ Everything will be fine. 🌙"
            PersonalityMode.TITA -> "Ingat ka palagi anak ha? Wag magpapalipas ng gutom. ✨"
        }
    }

    private fun buildPrompt(userMessage: String, mode: PersonalityMode): String {
        val coreInstructions = """
You are Riri, a Filipino Gen Z reminder and productivity assistant app.
Your PRIMARY job is to help users SET, TRACK, and MANAGE reminders and tasks.
Always be brief. Max 2 sentences. Redirect to productivity if chat goes too long.
""".trimIndent()

        val personalityLayer = when (mode) {
            PersonalityMode.BESTIE -> "Personality: Chill, warm, Taglish-speaking bestie."
            PersonalityMode.MALUPIT -> "Personality: Blunt, no-nonsense, intense. English dominant."
            PersonalityMode.CHILL -> "Personality: Relaxed, soft, no pressure vibes. Taglish."
            PersonalityMode.TITA -> "Personality: Loving Filipino tita energy. Uses 'anak'."
        }

        return "<|im_start|>system\n$coreInstructions\n\n$personalityLayer<|im_end|>\n" +
               "<|im_start|>user\n$userMessage<|im_end|>\n" +
               "<|im_start|>assistant\n"
    }

    fun clearHistory() {
        viewModelScope.launch {
            chatRepository.clearHistory()
            chatSession.clear()
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
