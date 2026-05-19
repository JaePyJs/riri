package com.riri.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val DarkColorScheme = darkColorScheme(
    primary = PrimaryViolet,
    secondary = AmberSecondary,
    tertiary = MutedText,
    background = DeepCharcoalBg,
    surface = SurfaceBg,
    onPrimary = Color.White,
    onSecondary = DeepCharcoalBg,
    onTertiary = DeepCharcoalBg,
    onBackground = OffWhiteText,
    onSurface = OffWhiteText,
    surfaceVariant = SurfaceBg,
    onSurfaceVariant = MutedText
)

@Composable
fun RiriTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        typography = Typography, // We'll define this next
        content = content
    )
}
