package com.riri.app.core.ai

import com.riri.app.data.db.entities.Reminder

class ChatSession {
    var lastIntent: RiriIntent? = null
    var pendingReminder: Reminder? = null
    
    fun clear() {
        lastIntent = null
        pendingReminder = null
    }
}
