package com.riri.app.core.ai

import java.time.LocalDateTime
import java.time.ZoneId
import java.util.regex.Pattern

data class ParsedReminder(
    val title: String,
    val dueDateTime: Long,
    val isRecurring: Boolean = false,
    val recurringInterval: String? = null
)

class TaglishParser {
    fun parse(input: String): ParsedReminder {
        val now = LocalDateTime.now()
        var targetDateTime = now.plusHours(1) // Default to 1 hour from now
        
        val lowerInput = input.lowercase()

        // 1. Determine the Base Date
        if (lowerInput.contains("bukas") || lowerInput.contains("tomorrow")) {
            targetDateTime = now.plusDays(1)
        } else if (lowerInput.contains("makalawa") || lowerInput.contains("day after tomorrow")) {
            targetDateTime = now.plusDays(2)
        } else if (lowerInput.contains("linggo") || lowerInput.contains("next week")) {
            targetDateTime = now.plusWeeks(1)
        } else if (lowerInput.contains("mamaya") || lowerInput.contains("later")) {
            targetDateTime = now.plusHours(2)
        } else if (lowerInput.contains("tonight") || lowerInput.contains("mamayang gabi")) {
            targetDateTime = now.withHour(20).withMinute(0)
            if (targetDateTime.isBefore(now)) targetDateTime = targetDateTime.plusDays(1)
        }

        // 2. Extract Time
        val timePattern = Pattern.compile("(\\d{1,2})(:(\\d{2}))?\\s*(am|pm|ng umaga|ng hapon|ng gabi)?")
        val matcher = timePattern.matcher(lowerInput)
        if (matcher.find()) {
            var hour = matcher.group(1)?.toInt() ?: targetDateTime.hour
            val minute = matcher.group(3)?.toInt() ?: 0
            val period = matcher.group(4)

            // Normalize hour based on period
            if (period != null) {
                if ((period.contains("pm") || period.contains("hapon") || period.contains("gabi")) && hour < 12) {
                    hour += 12
                } else if ((period.contains("am") || period.contains("umaga")) && hour == 12) {
                    hour = 0
                }
            } else if (hour < 8) { // Heuristic: if no period and hour < 8, assume PM (e.g. "at 5" -> 5 PM)
                hour += 12
            }

            targetDateTime = targetDateTime.withHour(hour).withMinute(minute).withSecond(0)
        }

        // 3. Extract Title (strip intent and time keywords)
        val stopPhrases = listOf(
            "(?i)set me (a )?reminder",
            "(?i)pa-remind",
            "(?i)remind me",
            "(?i)ipaalala",
            "(?i)paalala",
            "(?i)paki-remind",
            "(?i)bukas",
            "(?i)tomorrow",
            "(?i)makalawa",
            "(?i)next week",
            "(?i)ngayon",
            "(?i)later",
            "(?i)mamaya",
            "(?i)mamayang gabi",
            "(?i)tonight",
            "(?i)\\b(at|on|in|sa|ng|na|to|po|paki)\\b"
        )
        
        var title = input
        stopPhrases.forEach { phrase ->
            title = title.replace(Regex(phrase), "")
        }
        title = title.replace(timePattern.toRegex(), "").trim()
        
        // Final cleaning
        title = title.replace(Regex("^to\\s+"), "")
            .replace(Regex("^na\\s+"), "")
            .replace(Regex("\\s+"), " ")
            .trim()

        return ParsedReminder(
            title = title,
            dueDateTime = targetDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
        )
    }

    fun isValid(parsed: ParsedReminder): Boolean {
        // A valid title should not be empty and shouldn't just be the input if the input was a command
        return parsed.title.length > 2 && parsed.title.any { it.isLetter() }
    }
}
