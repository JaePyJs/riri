package com.riri.app.core.ai

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class WhisperEngine(private val context: Context) {
    // Sherpa-ONNX dependencies are currently unresolved in the build environment.
    // Mocking the engine for now to allow other components to compile.
    
    init {
        // Initialization mock
    }

    suspend fun transcribe(audioData: FloatArray): String = withContext(Dispatchers.Default) {
        // Mock transcription
        "Bili ng milk mamaya" 
    }
}
