package com.riri.app.core.utils

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileOutputStream

class ShareService(private val context: Context) {

    fun shareImage(bitmap: Bitmap, text: String = "Check out my Riri progress! 💜") {
        val cachePath = File(context.cacheDir, "images")
        cachePath.mkdirs()
        val file = File(cachePath, "riri_share_card.png")
        FileOutputStream(file).use { out ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        }

        val contentUri: Uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "image/png"
            putExtra(Intent.EXTRA_STREAM, contentUri)
            putExtra(Intent.EXTRA_TEXT, text)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        
        val chooser = Intent.createChooser(intent, "Share via")
        chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(chooser)
    }

    fun buildShareCardBitmap(data: com.riri.app.domain.usecase.ShareCardData): Bitmap {
        val width = 1080
        val height = 1920
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = android.graphics.Canvas(bitmap)
        
        val paint = android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG)
        
        // Background - Riri Deep Navy
        paint.color = android.graphics.Color.parseColor("#1A1A2E")
        canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)
        
        // Gradient Header
        val gradient = android.graphics.LinearGradient(
            0f, 0f, 0f, 400f,
            android.graphics.Color.parseColor("#7C5CBF"),
            android.graphics.Color.TRANSPARENT,
            android.graphics.Shader.TileMode.CLAMP
        )
        paint.shader = gradient
        canvas.drawRect(0f, 0f, width.toFloat(), 400f, paint)
        paint.shader = null

        // Watermark
        paint.color = android.graphics.Color.WHITE
        paint.alpha = 50
        paint.textSize = 40f
        canvas.drawText("Riri App - Laban Era", 50f, height - 50f, paint)
        
        // Content
        paint.alpha = 255
        paint.textSize = 80f
        paint.isFakeBoldText = true
        canvas.drawText(data.personalityTitle, 100f, 600f, paint)
        
        paint.textSize = 120f
        canvas.drawText("${data.streakCount} Day Streak!", 100f, 800f, paint)
        
        paint.textSize = 60f
        paint.isFakeBoldText = false
        canvas.drawText("Completion Rate: ${data.completionRate}%", 100f, 1000f, paint)
        
        return bitmap
    }
}
