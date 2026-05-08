package com.riri.app.ui.screens.onboarding

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Person
import com.riri.app.R
import com.riri.app.ui.theme.PrimaryViolet
import com.riri.app.ui.theme.RiriGradient
import org.koin.androidx.compose.koinViewModel

@Composable
fun OnboardingScreen(
    viewModel: OnboardingViewModel = koinViewModel(),
    onLetsGoClick: () -> Unit
) {
    val progress by viewModel.downloadProgress.collectAsState()
    val isDownloaded = viewModel.isModelDownloaded

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(com.riri.app.ui.theme.DeepCharcoalBg)
    ) {
        // Background Gradient Overlay
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(com.riri.app.ui.theme.PrimaryViolet.copy(alpha = 0.2f), Color.Transparent)
                    )
                )
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 32.dp)
                .verticalScroll(rememberScrollState()), // Added scroll for keyboard safety
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Glow effect for Riri
            Box(contentAlignment = Alignment.Center) {
                Box(
                    modifier = Modifier
                        .size(200.dp)
                        .background(com.riri.app.ui.theme.PrimaryViolet.copy(alpha = 0.15f), CircleShape)
                        .blur(40.dp)
                )
                Image(
                    painter = painterResource(id = R.drawable.welcoming),
                    contentDescription = "Riri Welcoming",
                    modifier = Modifier
                        .size(180.dp)
                )
            }

            Spacer(modifier = Modifier.height(48.dp))

            Text(
                text = buildAnnotatedString {
                    append("Welcome to ")
                    withStyle(style = SpanStyle(color = com.riri.app.ui.theme.AmberSecondary)) {
                        append("Riri")
                    }
                },
                style = MaterialTheme.typography.headlineLarge,
                color = Color.White,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "Alam mo na dapat. Gawin mo na.",
                style = MaterialTheme.typography.bodyLarge,
                color = Color.White,
                textAlign = TextAlign.Center,
                lineHeight = 26.sp,
                fontWeight = FontWeight.Medium
            )

            var name by remember { mutableStateOf("") }

            Text(
                text = "First off, ano itatawag ko sa'yo? ✨",
                style = MaterialTheme.typography.bodyLarge,
                color = com.riri.app.ui.theme.MutedText,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(16.dp))

            @OptIn(ExperimentalMaterial3Api::class)
            TextField(
                value = name,
                onValueChange = { name = it },
                placeholder = { Text("Enter your nickname...", color = com.riri.app.ui.theme.MutedText) },
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(16.dp))
                    .background(com.riri.app.ui.theme.SurfaceBg),
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent,
                    unfocusedContainerColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White
                ),
                singleLine = true,
                leadingIcon = { Icon(Icons.Default.Person, contentDescription = null, tint = com.riri.app.ui.theme.MutedText) }
            )

            Spacer(modifier = Modifier.height(32.dp))

            if (progress > 0f && progress < 1f) {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    LinearProgressIndicator(
                        progress = progress,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(10.dp)
                            .clip(RoundedCornerShape(5.dp)),
                        color = com.riri.app.ui.theme.PrimaryViolet,
                        trackColor = com.riri.app.ui.theme.SurfaceBg
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = "Downloading Riri's brain... ${(progress * 100).toInt()}%",
                        color = com.riri.app.ui.theme.MutedText,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium
                    )
                    
                    Spacer(modifier = Modifier.height(24.dp))
                    
                    TextButton(onClick = onLetsGoClick) {
                        Text("Skip download, use fallback AI ✌️", color = com.riri.app.ui.theme.MutedText, fontSize = 14.sp)
                    }
                }
            } else {
                Button(
                    onClick = { 
                        if (name.isNotBlank()) {
                            viewModel.saveName(name)
                            onLetsGoClick() 
                        }
                    },
                    enabled = name.isNotBlank(),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp)
                        .shadow(8.dp, RoundedCornerShape(28.dp)),
                    shape = RoundedCornerShape(28.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = com.riri.app.ui.theme.PrimaryViolet,
                        contentColor = Color.White,
                        disabledContainerColor = com.riri.app.ui.theme.SurfaceBg.copy(alpha = 0.5f),
                        disabledContentColor = com.riri.app.ui.theme.MutedText
                    )
                ) {
                    Text(
                        text = if (isDownloaded) "Let's Go! 🚀" else "Start with Lite AI ✨",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                }
                
                if (!isDownloaded) {
                    Spacer(modifier = Modifier.height(16.dp))
                    TextButton(onClick = { viewModel.startModelDownload() }) {
                        Text("Or download Full LLM (Recommended) 🧠", color = com.riri.app.ui.theme.MutedText, fontSize = 12.sp)
                    }
                }
            }
            
            if (progress >= 1f) {
                LaunchedEffect(Unit) {
                    onLetsGoClick()
                }
            }
        }
    }
}

private fun Modifier.blur(radius: androidx.compose.ui.unit.Dp): Modifier = this.then(
    // Placeholder for blur if not supported on all API levels, 
    // but we can use graphicsLayer for simple opacity/scaling
    Modifier.graphicsLayer {
        alpha = 0.8f
    }
)
