package com.riri.app.core.ai

enum class RiriIntent {
    REMINDER,
    CHAT,
    AMBIGUOUS
}

class IntentClassifier {
    fun classify(input: String): RiriIntent {
        val lower = input.lowercase()
        
        // Reminder patterns
        val reminderKeywords = listOf(
            "remind", "reminder", "wake me", "alarm", "schedule",
            "set a", "don't forget", "dont forget", "remember to", "notify me",
            "paalala", "pa-remind", "ipaalala", "tandaan", "i-schedule",
            "at ", "by ", "tomorrow", "tonight", "later", "bukas", "mamaya"
        )
        
        // Chat/Greeting patterns
        val chatKeywords = listOf(
            "hello", "hi ", "kumusta", "musta", "hoy", "riri", "haha", "lmao",
            "salamat", "thanks", "thank you", "okay", "sige", "geh", "nice"
        )

        val hasReminder = reminderKeywords.any { lower.contains(it) }
        val hasChat = chatKeywords.any { lower.startsWith(it) } || chatKeywords.any { lower == it }

        return when {
            hasReminder -> RiriIntent.REMINDER
            hasChat -> RiriIntent.CHAT
            else -> RiriIntent.AMBIGUOUS
        }
    }
}
