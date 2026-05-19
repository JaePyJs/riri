package com.riri.app.core.ai

import android.content.Context
import android.util.Log
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.File
import java.io.FileOutputStream
class ModelDownloadManager(private val context: Context) {
    private val TAG = "ModelDownloadManager"
    private val _downloadProgress = MutableStateFlow(0f)
    val downloadProgress: StateFlow<Float> = _downloadProgress.asStateFlow()

    val isDownloaded: Boolean
        get() = File(context.filesDir, MODEL_FILE_NAME).exists()

    suspend fun downloadModel() {
        withContext(Dispatchers.IO) {
            val target = File(context.filesDir, MODEL_FILE_NAME)
            if (target.exists()) {
                _downloadProgress.value = 1f
                return@withContext
            }
            
            _downloadProgress.value = 0.01f
            Log.d(TAG, "Starting download from: $MODEL_URL")

            val client = OkHttpClient.Builder()
                .followRedirects(true)
                .build()
                
            val request = Request.Builder()
                .url(MODEL_URL)
                .build()

            try {
                val response = client.newCall(request).execute()
                if (!response.isSuccessful) {
                    val errorMsg = "Download failed: ${response.code} ${response.message}"
                    Log.e(TAG, errorMsg)
                    response.close()
                    throw IllegalStateException(errorMsg)
                }

                val body = response.body ?: run {
                    response.close()
                    throw IllegalStateException("Model download returned empty body")
                }

                val totalBytes = body.contentLength()
                Log.d(TAG, "Total bytes: $totalBytes")
                val inputStream = body.byteStream()

                FileOutputStream(target).use { output ->
                    val buffer = ByteArray(8 * 1024)
                    var bytesRead: Int
                    var downloaded = 0L

                    while (inputStream.read(buffer).also { bytesRead = it } >= 0) {
                        if (!kotlin.coroutines.coroutineContext.isActive) {
                            Log.d(TAG, "Download cancelled")
                            throw CancellationException("Model download cancelled")
                        }
                        output.write(buffer, 0, bytesRead)
                        downloaded += bytesRead
                        
                        if (totalBytes > 0) {
                            val prog = (downloaded.toFloat() / totalBytes.toFloat()).coerceIn(0.01f, 0.99f)
                            _downloadProgress.value = prog
                        } else {
                            // If chunked, just increment a bit to show activity
                            _downloadProgress.value = (_downloadProgress.value + 0.001f).coerceAtMost(0.99f)
                        }
                        
                        if (downloaded % (1024 * 1024) == 0L) { // Log every MB
                            Log.d(TAG, "Downloaded: ${downloaded / 1024 / 1024}MB")
                        }
                    }
                }
                _downloadProgress.value = 1f
                Log.d(TAG, "Download complete")
                response.close()
            } catch (e: Exception) {
                Log.e(TAG, "Download error", e)
                if (target.exists()) target.delete()
                throw e
            }
        }
    }
}

// Using a valid .task model URL for MediaPipe GenAI (AfiOne Gemma 1B)
private const val MODEL_URL = "https://huggingface.co/AfiOne/gemma3-1b-it-int4.task/resolve/main/gemma3-1b-it-int4.task?download=true"
private const val MODEL_FILE_NAME = "riri_model.task"
