package com.riri.app.ui.screens.profile

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.riri.app.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    viewModel: ProfileViewModel,
    onSettingsClick: () -> Unit,
    onShareClick: () -> Unit,
    onChaosReportClick: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text("Profile", style = MaterialTheme.typography.titleMedium, color = Color.White, fontWeight = FontWeight.Bold) },
                actions = {
                    IconButton(onClick = onSettingsClick) {
                        Icon(Icons.Default.Settings, contentDescription = "Settings", tint = com.riri.app.ui.theme.MutedText)
                    }
                },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                    containerColor = com.riri.app.ui.theme.HeaderBg.copy(alpha = 0.9f)
                ),
                modifier = Modifier.clip(RoundedCornerShape(bottomStart = 24.dp, bottomEnd = 24.dp))
            )
        },
        containerColor = com.riri.app.ui.theme.DeepCharcoalBg
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            horizontalAlignment = Alignment.CenterHorizontally,
            contentPadding = PaddingValues(bottom = 100.dp)
        ) {
            item {
                Column(
                    modifier = Modifier
                        .padding(vertical = 24.dp)
                        .padding(horizontal = 24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Box(
                            modifier = Modifier
                                .size(150.dp)
                                .background(com.riri.app.ui.theme.AmberSecondary.copy(alpha = 0.1f), CircleShape)
                        )
                        Image(
                            painter = painterResource(id = R.drawable.streak_celebration),
                            contentDescription = "Riri Celebration",
                            modifier = Modifier.size(140.dp)
                        )
                    }
                    
                    Text(
                        text = uiState.userName,
                        style = MaterialTheme.typography.headlineMedium,
                        color = Color.White,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(top = 16.dp)
                    )
                    
                    Text(
                        text = "${uiState.currentTitle} 👑",
                        style = MaterialTheme.typography.bodyLarge,
                        color = com.riri.app.ui.theme.AmberSecondary,
                        fontWeight = FontWeight.Bold
                    )
                    
                    Spacer(modifier = Modifier.height(12.dp))
                    
                    Row(
                        modifier = Modifier
                            .background(com.riri.app.ui.theme.PrimaryViolet.copy(alpha = 0.15f), CircleShape)
                            .border(1.dp, com.riri.app.ui.theme.PrimaryViolet.copy(alpha = 0.3f), CircleShape)
                            .padding(horizontal = 12.dp, vertical = 6.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("🔥", fontSize = 14.sp)
                        Spacer(modifier = Modifier.width(6.dp))
                        Text("${uiState.streakCount} day streak", color = com.riri.app.ui.theme.PrimaryViolet, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        StatCard(label = "${uiState.completionRate}% this week", modifier = Modifier.weight(1f))
                        StatCard(label = "${uiState.totalDone} done", modifier = Modifier.weight(1f))
                        StatCard(label = "${uiState.bestStreak} day best", modifier = Modifier.weight(1f))
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    Spacer(modifier = Modifier.height(12.dp))

                    Button(
                        onClick = onChaosReportClick,
                        modifier = Modifier.fillMaxWidth().height(56.dp),
                        shape = RoundedCornerShape(28.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = com.riri.app.ui.theme.SurfaceBg)
                    ) {
                        Text("View Weekly Chaos Report 🧾", fontWeight = FontWeight.Bold, color = com.riri.app.ui.theme.AmberSecondary)
                    }
                }
            }

            item {
                Column(modifier = Modifier.padding(horizontal = 24.dp)) {
                    Text("Achievements", style = MaterialTheme.typography.titleMedium, color = Color.White, fontWeight = FontWeight.Bold)
                    Spacer(modifier = Modifier.height(16.dp))
                    
                    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            AchievementCard(emoji = "🔥", title = "Slay Era", subtitle = "Completed 10 tasks", color = com.riri.app.ui.theme.PrimaryViolet, modifier = Modifier.weight(1f))
                            AchievementCard(emoji = "⭐", title = "Sana All", subtitle = "Perfect week", color = com.riri.app.ui.theme.AmberSecondary, isRare = true, modifier = Modifier.weight(1f))
                        }
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            AchievementCard(emoji = "📝", title = "Plano Queen", subtitle = "Planned 5 days", color = com.riri.app.ui.theme.SuccessGreen, modifier = Modifier.weight(1f))
                            AchievementCard(emoji = "🎉", title = "First Laban", subtitle = "Joined Riri", color = com.riri.app.ui.theme.OverdueOrange, modifier = Modifier.weight(1f))
                        }
                    }
                }
            }

            item {
                Box(
                    modifier = Modifier
                        .padding(24.dp)
                        .background(com.riri.app.ui.theme.SurfaceBg, RoundedCornerShape(16.dp))
                        .padding(16.dp)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                        Image(painterResource(id = R.drawable.achievement), contentDescription = null, modifier = Modifier.size(64.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text("You and Riri: 14 days strong 💜", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 15.sp)
                            Spacer(modifier = Modifier.height(12.dp))
                            LinearProgressIndicator(
                                progress = uiState.bondProgress,
                                modifier = Modifier.fillMaxWidth().height(6.dp).clip(CircleShape),
                                color = com.riri.app.ui.theme.PrimaryViolet,
                                trackColor = com.riri.app.ui.theme.DeepCharcoalBg
                            )
                            Spacer(modifier = Modifier.height(6.dp))
                            Text("16 days to unlock next bond level", color = com.riri.app.ui.theme.MutedText, fontSize = 11.sp)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun StatCard(label: String, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .background(com.riri.app.ui.theme.SurfaceBg, RoundedCornerShape(12.dp))
            .padding(vertical = 12.dp, horizontal = 4.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(text = label, color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Medium, textAlign = androidx.compose.ui.text.style.TextAlign.Center)
    }
}

@Composable
fun AchievementCard(
    emoji: String,
    title: String,
    subtitle: String,
    color: Color,
    isRare: Boolean = false,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(com.riri.app.ui.theme.SurfaceBg)
            .padding(16.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            if (isRare) {
                Box(
                    modifier = Modifier
                        .align(Alignment.End)
                        .background(com.riri.app.ui.theme.AmberSecondary, RoundedCornerShape(4.dp))
                        .padding(horizontal = 6.dp, vertical = 2.dp)
                ) {
                    Text("RARE", fontSize = 9.sp, fontWeight = FontWeight.Black, color = com.riri.app.ui.theme.HeaderBg)
                }
            }
            Text(emoji, fontSize = 32.sp)
            Spacer(modifier = Modifier.height(8.dp))
            Text(title, color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Bold)
            Text(subtitle, color = com.riri.app.ui.theme.MutedText, fontSize = 11.sp, fontWeight = FontWeight.Medium)
        }
    }
}
