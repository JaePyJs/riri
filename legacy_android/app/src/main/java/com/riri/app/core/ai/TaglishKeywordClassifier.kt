package com.riri.app.core.ai

import com.riri.app.domain.model.ReminderCategory

class TaglishKeywordClassifier {
    fun classify(input: String): ReminderCategory {
        val lowerInput = input.lowercase()
        
        return when {
            // SCHOOL
            containsAny(lowerInput, listOf("submit", "exam", "quiz", "homework", "project", "thesis", "recitation", "clearance", "enrollment", "aral", "assignment", "school")) -> 
                ReminderCategory.SCHOOL
                
            // WORK
            containsAny(lowerInput, listOf("meeting", "deadline", "report", "client", "email", "presentation", "overtime", "trabaho", "office", "work")) -> 
                ReminderCategory.WORK
                
            // HEALTH
            containsAny(lowerInput, listOf("check-up", "gamot", "inom ng gamot", "doctor", "hospital", "vitamins", "exercise", "diet", "gym", "health")) -> 
                ReminderCategory.HEALTH
                
            // SOCIAL
            containsAny(lowerInput, listOf("kaarawan", "birthday", "inuman", "tambay", "date", "anniversary", "reunion", "party", "hangout", "kita")) -> 
                ReminderCategory.SOCIAL
                
            // ERRANDS
            containsAny(lowerInput, listOf("bayad", "bills", "grocery", "palengke", "padala", "load", "pickup", "delivery", "bili", "utang")) -> 
                ReminderCategory.ERRANDS
                
            // BAHALA NA (Special Riri Category)
            lowerInput.contains("bahala na") || lowerInput.contains("ewan") -> 
                ReminderCategory.BAHALA_NA
                
            else -> ReminderCategory.PERSONAL
        }
    }

    private fun containsAny(input: String, keywords: List<String>): Boolean {
        return keywords.any { input.contains(it) }
    }
}
