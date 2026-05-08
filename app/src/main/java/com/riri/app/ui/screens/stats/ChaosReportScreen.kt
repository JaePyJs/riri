package com.riri.app.ui.screens.stats

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.filled.Image
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.riri.app.data.db.entities.UserStats
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import android.os.Build
import android.net.Uri
import androidx.compose.ui.platform.LocalContext
import com.riri.app.ui.theme.PrimaryViolet
import com.riri.app.ui.theme.AmberSecondary
import com.riri.app.ui.theme.RiriGradient
import coil.compose.rememberAsyncImagePainter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChaosReportScreen(
    stats: UserStats?,
    onBackClick: () -> Unit,
    onShareClick: () -> Unit
) {
    var selectedImageUri by remember { mutableStateOf<Uri?>(null) }
    val context = LocalContext.current
    val launcher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        selectedImageUri = uri
    }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text("Weekly Chaos Report", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold, color = Color.White) },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = Color.White)
                    }
                },
                actions = {
                    IconButton(onClick = { launcher.launch("image/*") }) {
                        Icon(imageVector = Icons.Default.Image, contentDescription = "Change background", tint = AmberSecondary, modifier = Modifier.size(24.dp))
                    }
                },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                    containerColor = Color.Transparent
                )
            )
        },
        containerColor = com.riri.app.ui.theme.DeepCharcoalBg
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // Background Image or Glow
            if (selectedImageUri != null) {
                androidx.compose.foundation.Image(
                    painter = rememberAsyncImagePainter(selectedImageUri),
                    contentDescription = null,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop,
                    alpha = 0.5f
                )
            } else {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(PrimaryViolet.copy(alpha = 0.15f), Color.Transparent),
                            center = center,
                            radius = size.minDimension
                        )
                    )
                }
            }

            // Dark overlay for readability
            Box(modifier = Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.3f)))

            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Receipts don't lie. 🧾",
                    style = MaterialTheme.typography.headlineSmall,
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
                
                Spacer(modifier = Modifier.height(8.dp))
                
                Text(
                    text = "Heto ang ganap mo this week...",
                    style = MaterialTheme.typography.bodyMedium,
                    color = com.riri.app.ui.theme.MutedText
                )

                Spacer(modifier = Modifier.height(32.dp))

                // The Report Card
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f),
                    shape = RoundedCornerShape(32.dp),
                    colors = CardDefaults.cardColors(containerColor = com.riri.app.ui.theme.SurfaceBg)
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(
                                text = stats?.personalityTitle ?: "The Procrastinator Era",
                                style = MaterialTheme.typography.headlineMedium,
                                color = AmberSecondary,
                                fontWeight = FontWeight.ExtraBold,
                                textAlign = TextAlign.Center
                            )
                            Spacer(modifier = Modifier.height(16.dp))
                            HorizontalDivider(color = com.riri.app.ui.theme.MutedText.copy(alpha = 0.2f), thickness = 1.dp)
                        }

                        // Stats Grid
                        Column(
                            modifier = Modifier.fillMaxWidth(),
                            verticalArrangement = Arrangement.spacedBy(20.dp)
                        ) {
                            StatRow("Total Tasks Set", "${stats?.totalSet ?: 0}", "Busy yarn?")
                            StatRow("Tasks Completed", "${stats?.totalCompleted ?: 0}", "Slay!")
                            StatRow("Snoozed/Ignored", "${stats?.totalIgnored ?: 0}", "Tulog muna?")
                            StatRow("Current Streak", "${stats?.currentStreak ?: 0} Days", "Consistency check!")
                        }

                        // Procrastination Score
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(
                                text = "Procrastination Score",
                                style = MaterialTheme.typography.labelSmall,
                                color = com.riri.app.ui.theme.MutedText
                            )
                            Text(
                                text = "${((stats?.procrastinationScore ?: 0f) * 100).toInt()}%",
                                style = MaterialTheme.typography.displaySmall,
                                color = if ((stats?.procrastinationScore ?: 0f) > 0.5f) Color.Red else com.riri.app.ui.theme.SuccessGreen,
                                fontWeight = FontWeight.Bold
                            )
                        }

                        Button(
                            onClick = onShareClick,
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(56.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent),
                            shape = RoundedCornerShape(28.dp),
                            contentPadding = PaddingValues()
                        ) {
                            Box(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .background(RiriGradient),
                                contentAlignment = Alignment.Center
                            ) {
                                Text("Share to IG/FB Story 🤳", color = Color.White, fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun StatRow(label: String, value: String, comment: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column {
            Text(text = label, style = MaterialTheme.typography.bodySmall, color = com.riri.app.ui.theme.MutedText)
            Text(text = comment, style = MaterialTheme.typography.labelSmall, color = AmberSecondary.copy(alpha = 0.7f))
        }
        Text(text = value, style = MaterialTheme.typography.titleLarge, color = Color.White, fontWeight = FontWeight.Bold)
    }
}
