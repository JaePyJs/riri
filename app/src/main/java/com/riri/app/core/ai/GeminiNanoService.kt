package com.riri.app.core.ai

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class GeminiNanoService(private val context: Context) {
    suspend fun runPrompt(prompt: String): GeminiNanoResult = withContext(Dispatchers.IO) {
        val manager = loadManager()
            ?: return@withContext GeminiNanoResult.Failure(GeminiNanoError.HardwareUnavailable)
        val config = buildConfig(MODEL_NAME)
            ?: return@withContext GeminiNanoResult.Failure(GeminiNanoError.HardwareUnavailable)

        return@withContext try {
            if (!invokeIsModelAvailable(manager, config)) {
                GeminiNanoResult.Failure(GeminiNanoError.ModelUnavailable)
            } else {
                val responseText = invokeGenerate(manager, config, prompt)
                if (responseText.isNullOrBlank()) {
                    GeminiNanoResult.Failure(GeminiNanoError.EmptyResponse)
                } else {
                    GeminiNanoResult.Success(responseText)
                }
            }
        } catch (e: Exception) {
            val error = when {
                e.javaClass.simpleName == "ModelNotDownloadedException" -> GeminiNanoError.ModelNotDownloaded
                e is UnsupportedOperationException -> GeminiNanoError.HardwareUnavailable
                else -> GeminiNanoError.Unknown
            }
            GeminiNanoResult.Failure(error)
        }
    }

    private fun loadManager(): Any? {
        return runCatching {
            val clazz = Class.forName("com.google.ai.edge.aicore.GenerativeModelManager")
            val getInstance = clazz.getMethod("getInstance", Context::class.java)
            getInstance.invoke(null, context)
        }.getOrNull()
    }

    private fun buildConfig(modelName: String): Any? {
        return runCatching {
            val configClass = Class.forName("com.google.ai.edge.aicore.GenerativeModelConfig")
            val directCtor = configClass.constructors.firstOrNull {
                it.parameterTypes.size == 1 && it.parameterTypes[0] == String::class.java
            }
            if (directCtor != null) {
                return@runCatching directCtor.newInstance(modelName)
            }

            val builderClass = Class.forName("com.google.ai.edge.aicore.GenerativeModelConfig\$Builder")
            val builder = builderClass.getConstructor().newInstance()
            builderClass.methods.firstOrNull { it.name == "setModelName" && it.parameterTypes.size == 1 }
                ?.invoke(builder, modelName)
            builderClass.methods.firstOrNull { it.name == "build" && it.parameterTypes.isEmpty() }
                ?.invoke(builder)
        }.getOrNull()
    }

    private fun invokeIsModelAvailable(manager: Any, config: Any): Boolean {
        return runCatching {
            val method = manager.javaClass.methods.firstOrNull {
                it.name == "isModelAvailable" && it.parameterTypes.size == 1
            }
            (method?.invoke(manager, config) as? Boolean) == true
        }.getOrDefault(false)
    }

    private fun invokeGenerate(manager: Any, config: Any, prompt: String): String? {
        val direct = invokeByName(manager, listOf(config, prompt), listOf("generate", "generateContent", "generateResponse"))
        if (direct != null) {
            return extractText(direct)
        }

        val session = invokeByName(manager, listOf(config), listOf("createSession", "startSession"))
            ?: return null
        val sessionResult = invokeByName(session, listOf(prompt), listOf("generate", "generateContent", "generateResponse"))
        return extractText(sessionResult)
    }

    private fun invokeByName(target: Any, args: List<Any>, names: List<String>): Any? {
        val methods = target.javaClass.methods
        for (name in names) {
            val method = methods.firstOrNull { it.name == name && it.parameterTypes.size == args.size }
            if (method != null) {
                return runCatching { method.invoke(target, *args.toTypedArray()) }.getOrNull()
            }
        }
        return null
    }

    private fun extractText(result: Any?): String? {
        if (result == null) return null
        if (result is String) return result
        val textMethod = result.javaClass.methods.firstOrNull {
            it.name == "getText" && it.parameterTypes.isEmpty()
        }
        return (textMethod?.invoke(result) as? String) ?: result.toString()
    }

    companion object {
        private const val MODEL_NAME = "gemini-nano"
    }
}

sealed class GeminiNanoResult {
    data class Success(val text: String) : GeminiNanoResult()
    data class Failure(val error: GeminiNanoError) : GeminiNanoResult()
}

enum class GeminiNanoError {
    ModelUnavailable,
    ModelNotDownloaded,
    HardwareUnavailable,
    EmptyResponse,
    Unknown
}
