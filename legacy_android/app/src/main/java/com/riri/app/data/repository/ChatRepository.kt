package com.riri.app.data.repository

import com.riri.app.data.db.dao.ChatDao
import com.riri.app.data.db.entities.ChatMessage
import kotlinx.coroutines.flow.Flow

class ChatRepository(private val chatDao: ChatDao) {
    fun getMessages(): Flow<List<ChatMessage>> = chatDao.getAllMessages()
    
    suspend fun sendMessage(text: String, isUser: Boolean, stickerName: String? = null) {
        chatDao.insertMessage(ChatMessage(text = text, isUser = isUser, stickerName = stickerName))
    }
    
    suspend fun clearHistory() {
        chatDao.clearHistory()
    }
}
