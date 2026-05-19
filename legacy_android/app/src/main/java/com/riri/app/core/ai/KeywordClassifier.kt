package com.riri.app.core.ai

import com.riri.app.domain.model.ReminderCategory

class KeywordClassifier {
    fun classify(input: String): ReminderCategory {
        val text = input.lowercase()

        return when {
            text.contains("bahala na") ||
                text.contains("sige na") ||
                text.contains("whatever") ||
                text.contains("depende") ||
                text.contains("di ko alam") -> ReminderCategory.BAHALA_NA
            text.contains("exam") || text.contains("class") || text.contains("school") -> ReminderCategory.SCHOOL
            text.contains("work") || text.contains("meeting") || text.contains("deadline") -> ReminderCategory.WORK
            text.contains("doctor") || text.contains("medicine") || text.contains("gym") -> ReminderCategory.HEALTH
            text.contains("party") || text.contains("date") || text.contains("hangout") -> ReminderCategory.SOCIAL
            text.contains("grocery") || text.contains("buy") || text.contains("bili") -> ReminderCategory.ERRANDS
            else -> ReminderCategory.PERSONAL
        }
    }
}
