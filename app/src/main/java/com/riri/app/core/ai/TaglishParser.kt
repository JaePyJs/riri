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
        if (lowerInput.contains("bukas")) {
            targetDateTime = now.plusDays(1)
        } else if (lowerInput.contains("makalawa")) {
            targetDateTime = now.plusDays(2)
        } else if (lowerInput.contains("linggo")) {
            targetDateTime = now.plusWeeks(1)
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
        var title = input
            .replace(Regex("(?i)set me (a )?reminder"), "")
            .replace(Regex("(?i)pa-remind"), "")
            .replace(Regex("(?i)remind me"), "")
            .replace(Regex("(?i)bukas"), "")
            .replace(Regex("(?i)makalawa"), "")
            .replace(Regex("(?i)ngayon"), "")
            .replace(Regex("(?i)later"), "")
            .replace(timePattern.toRegex(), "")
            .trim()
            .replace(Regex("^to\\s+"), "") // Remove leading "to"
            .replace(Regex("^na\\s+"), "") // Remove leading "na"
            .trim()

        if (title.isEmpty()) title = input

        return ParsedReminder(
            title = title,
            dueDateTime = targetDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
        )
    }
}
