package com.riri.app.core.ai

import android.content.Context
import ai.onnxruntime.OnnxTensor
import ai.onnxruntime.OrtEnvironment
import ai.onnxruntime.OrtSession
import com.riri.app.domain.model.ReminderCategory
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.util.Collections

class CategoryClassifier(private val context: Context) {
    private var ortEnv: OrtEnvironment = OrtEnvironment.getEnvironment()
    private var ortSession: OrtSession? = null
    private val modelFileName = "mobilebert-multilingual-classification.onnx"

    init {
        try {
            loadModel()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun loadModel() {
        val modelResId = context.resources.getIdentifier(
            modelFileName.removeSuffix(".onnx"), 
            "raw", 
            context.packageName
        )
        if (modelResId == 0) return

        val modelBytes = context.resources.openRawResource(modelResId).readBytes()
        ortSession = ortEnv.createSession(modelBytes)
    }

    suspend fun classify(text: String): ReminderCategory = withContext(Dispatchers.Default) {
        try {
            val session = ortSession ?: return@withContext ReminderCategory.PERSONAL
            
            // TODO: Replace with actual WordPiece tokenization logic
            // Standard BERT input: [input_ids, attention_mask, token_type_ids]
            val maxLen = 128
            val inputIds = LongArray(maxLen) { 0L }
            val attentionMask = LongArray(maxLen) { 0L }
            
            // Very basic tokenization simulation
            inputIds[0] = 101L // [CLS]
            text.lowercase().split(" ").take(maxLen - 2).forEachIndexed { index, _ ->
                inputIds[index + 1] = 100L // [UNK] placeholder
                attentionMask[index + 1] = 1L
            }
            inputIds[text.split(" ").size + 1] = 102L // [SEP]
            attentionMask[0] = 1L
            attentionMask[text.split(" ").size + 1] = 1L

            val inputNames = session.inputNames.toList()
            val container = mutableMapOf<String, OnnxTensor>()
            
            container[inputNames[0]] = OnnxTensor.createTensor(ortEnv, arrayOf(inputIds))
            container[inputNames[1]] = OnnxTensor.createTensor(ortEnv, arrayOf(attentionMask))
            
            // Some models require token_type_ids
            if (inputNames.size > 2) {
                container[inputNames[2]] = OnnxTensor.createTensor(ortEnv, arrayOf(LongArray(maxLen) { 0L }))
            }

            val result = session.run(container)
            val output = result[0].value as Array<FloatArray>
            val probabilities = output[0]
            
            val maxIndex = probabilities.indices.maxByOrNull { probabilities[it] } ?: -1
            mapIndexToCategory(maxIndex)
        } catch (e: Exception) {
            ReminderCategory.PERSONAL
        }
    }

    private fun mapIndexToCategory(index: Int): ReminderCategory {
        return when (index) {
            0 -> ReminderCategory.SCHOOL
            1 -> ReminderCategory.WORK
            2 -> ReminderCategory.HEALTH
            3 -> ReminderCategory.SOCIAL
            4 -> ReminderCategory.ERRANDS
            else -> ReminderCategory.PERSONAL
        }
    }
}
