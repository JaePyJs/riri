package com.riri.app.ui.screens.dashboard

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.geometry.Offset
import com.riri.app.data.db.entities.Reminder
import com.riri.app.ui.components.DashboardState
import com.riri.app.ui.components.RiriAssetMapper
import com.riri.app.ui.theme.RiriGradient
import kotlinx.coroutines.flow.StateFlow

data class DashboardUiState(
    val userName: String = "Laban",
    val characterState: DashboardState = DashboardState.READY,
    val reminders: List<Reminder> = emptyList(),
    val isLoading: Boolean = false
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    uiStateFlow: StateFlow<DashboardUiState>,
    onAddReminderClick: () -> Unit,
    onReminderClick: (Reminder) -> Unit,
    onReminderToggle: (Reminder) -> Unit,
    onReminderDelete: (Reminder) -> Unit,
    onProfileClick: () -> Unit,
    onChatClick: () -> Unit
) {
    val uiState by uiStateFlow.collectAsState()

    Scaffold(
        containerColor = com.riri.app.ui.theme.DeepCharcoalBg,
        floatingActionButton = {
            FloatingActionButton(
                onClick = onAddReminderClick,
                containerColor = Color.Transparent,
                elevation = FloatingActionButtonDefaults.elevation(0.dp),
                modifier = Modifier.padding(bottom = 16.dp, end = 8.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .background(RiriGradient, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Add,
                        contentDescription = "Add Reminder",
                        tint = Color.White
                    )
                }
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(bottom = padding.calculateBottomPadding())
        ) {
            // Header with rounded bottom
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(bottomStart = 32.dp, bottomEnd = 32.dp))
                    .background(com.riri.app.ui.theme.HeaderBg)
                    .padding(top = 48.dp, start = 24.dp, end = 24.dp, bottom = 32.dp)
            ) {
                Column {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                text = "Hi, ${uiState.userName}! 👋",
                                style = MaterialTheme.typography.headlineSmall,
                                fontWeight = FontWeight.Bold,
                                color = Color.White
                            )
                            Text(
                                text = "G na tayo today! ✨",
                                style = MaterialTheme.typography.bodyMedium,
                                color = com.riri.app.ui.theme.AmberSecondary,
                                fontWeight = FontWeight.Medium
                            )
                        }
                        
                        // Navigation moved to BottomBar
                    }
                    
                    Spacer(modifier = Modifier.height(24.dp))
                    
                    // Riri Status Card
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(com.riri.app.ui.theme.SurfaceBg, RoundedCornerShape(20.dp))
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Image(
                            painter = painterResource(id = RiriAssetMapper.getDrawableForState(uiState.characterState)),
                            contentDescription = "Riri",
                            modifier = Modifier.size(64.dp)
                        )
                        Spacer(modifier = Modifier.width(16.dp))
                        Column {
                            Text(
                                text = RiriAssetMapper.getGenZCopyForState(uiState.characterState),
                                style = MaterialTheme.typography.bodyMedium,
                                fontWeight = FontWeight.Bold,
                                color = Color.White
                            )
                            Text(
                                text = "You have ${uiState.reminders.filter { !it.isCompleted }.size} tasks left.",
                                style = MaterialTheme.typography.bodySmall,
                                color = com.riri.app.ui.theme.MutedText
                            )
                        }
                    }
                }
            }

            // Tasks List
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 24.dp, vertical = 24.dp)
            ) {
                Text(
                    text = "Your Tasks",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    modifier = Modifier.padding(bottom = 16.dp)
                )

                if (uiState.reminders.isEmpty()) {
                    EmptyRemindersView(modifier = Modifier.weight(1f))
                } else {
                    LazyColumn(
                        modifier = Modifier.weight(1f),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        items(uiState.reminders) { reminder ->
                            ReminderItem(
                                reminder = reminder,
                                onClick = { onReminderClick(reminder) },
                                onToggle = { onReminderToggle(reminder) }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun ReminderItem(
    reminder: Reminder,
    onClick: () -> Unit,
    onToggle: () -> Unit
) {
    val isOverdue = !reminder.isCompleted && reminder.dueDateTime < System.currentTimeMillis()
    val borderColor = when {
        reminder.isCompleted -> com.riri.app.ui.theme.SuccessGreen
        isOverdue -> com.riri.app.ui.theme.OverdueOrange
        else -> com.riri.app.ui.theme.PrimaryViolet
    }

    Surface(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        color = com.riri.app.ui.theme.SurfaceBg
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .drawLeftBorder(borderColor, 4.dp)
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(
                onClick = onToggle,
                modifier = Modifier.size(24.dp)
            ) {
                Icon(
                    painter = painterResource(
                        id = if (reminder.isCompleted) com.riri.app.R.drawable.streak_celebration else com.riri.app.R.drawable.inactive
                    ),
                    contentDescription = null,
                    tint = if (reminder.isCompleted) com.riri.app.ui.theme.SuccessGreen else com.riri.app.ui.theme.MutedText,
                    modifier = Modifier.size(24.dp)
                )
            }

            Spacer(modifier = Modifier.width(16.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = reminder.title,
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Bold,
                    color = if (reminder.isCompleted) com.riri.app.ui.theme.MutedText else Color.White,
                    textDecoration = if (reminder.isCompleted) androidx.compose.ui.text.style.TextDecoration.LineThrough else null
                )
                
                val timeFormat = java.text.SimpleDateFormat("h:mm a", java.util.Locale.getDefault())
                val timeStr = timeFormat.format(java.util.Date(reminder.dueDateTime))
                
                Text(
                    text = timeStr,
                    style = MaterialTheme.typography.bodySmall,
                    fontWeight = FontWeight.Medium,
                    color = if (isOverdue) com.riri.app.ui.theme.OverdueOrange else com.riri.app.ui.theme.MutedText
                )
            }
        }
    }
}

private fun Modifier.drawLeftBorder(color: Color, width: Dp): Modifier = this.drawBehind {
    val strokeWidth = width.toPx()
    drawLine(
        color = color,
        start = Offset(0f, 0f),
        end = Offset(0f, size.height),
        strokeWidth = strokeWidth
    )
}

@Composable
fun EmptyRemindersView(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier,
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "Clean as a whistle! 💅",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
        )
    }
}
