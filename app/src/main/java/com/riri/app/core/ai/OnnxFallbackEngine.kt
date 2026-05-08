package com.riri.app.core.ai

import android.content.Context
import com.riri.app.domain.model.ReminderCategory
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class OnnxFallbackEngine(
    private val context: Context,
    private val categoryClassifier: CategoryClassifier,
    private val keywordClassifier: TaglishKeywordClassifier
) {
    private val modelFileName = "mobilebert-multilingual-classification.onnx"

    fun isModelAvailable(): Boolean {
        val resId = context.resources.getIdentifier(
            modelFileName.removeSuffix(".onnx"), 
            "raw", 
            context.packageName
        )
        return resId != 0
    }

    suspend fun categorize(input: String): ReminderCategory = withContext(Dispatchers.Default) {
        if (isModelAvailable()) {
            try {
                categoryClassifier.classify(input)
            } catch (e: Exception) {
                keywordClassifier.classify(input)
            }
        } else {
            keywordClassifier.classify(input)
        }
    }

    suspend fun isModelLoaded(): Boolean {
        // Simple check if the model is reachable and potentially initialized
        return isModelAvailable()
    }
}
