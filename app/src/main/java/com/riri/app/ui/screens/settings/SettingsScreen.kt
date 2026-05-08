package com.riri.app.ui.screens.settings

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.riri.app.R
import com.riri.app.domain.model.PersonalityMode

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    viewModel: SettingsViewModel,
    onBackClick: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    var showPrivacyDialog by remember { mutableStateOf(false) }
    var showSupportDialog by remember { mutableStateOf(false) }
    var showNameDialog by remember { mutableStateOf(false) }
    var tempName by remember { mutableStateOf(uiState.userName) }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text("Settings", style = MaterialTheme.typography.titleMedium, color = Color.White, fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = Color.White)
                    }
                },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                    containerColor = com.riri.app.ui.theme.HeaderBg
                ),
                modifier = Modifier.clip(RoundedCornerShape(bottomStart = 24.dp, bottomEnd = 24.dp))
            )
        },
        containerColor = com.riri.app.ui.theme.DeepCharcoalBg
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 24.dp)
        ) {
            item {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 32.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Image(
                        painter = painterResource(id = R.drawable.wink),
                        contentDescription = "Riri Wink",
                        modifier = Modifier
                            .size(100.dp)
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        text = "Riri is keeping your secrets safe! 🤫",
                        style = MaterialTheme.typography.bodyMedium,
                        color = com.riri.app.ui.theme.AmberSecondary,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            item {
                SettingsSectionTitle(title = "Personality Mode")
                PersonalitySelector(
                    selectedMode = uiState.personalityMode,
                    onModeSelected = { viewModel.setPersonalityMode(it) }
                )
            }

            item {
                Spacer(modifier = Modifier.height(24.dp))
                SettingsSectionTitle(title = "Preferences")
                SettingsToggleItem(
                    title = "Notifications",
                    subtitle = "Get reminders from Riri",
                    isChecked = uiState.notificationsEnabled,
                    onCheckedChange = { viewModel.toggleNotifications(it) }
                )
                
                SettingsStaticItem(
                    title = "Dark Mode Only",
                    subtitle = "Dark mode is life. You can't turn it off.",
                    trailing = {
                        Switch(
                            checked = true, 
                            onCheckedChange = null, 
                            enabled = false,
                            colors = SwitchDefaults.colors(
                                disabledUncheckedTrackColor = com.riri.app.ui.theme.SurfaceBg,
                                disabledCheckedTrackColor = com.riri.app.ui.theme.PrimaryViolet.copy(alpha = 0.5f)
                            )
                        )
                    }
                )
            }

            item {
                Spacer(modifier = Modifier.height(24.dp))
                SettingsSectionTitle(title = "Account & Safety")
                SettingsClickableItem(
                    title = "Your Name: ${uiState.userName}", 
                    onClick = { 
                        tempName = uiState.userName
                        showNameDialog = true 
                    }
                )
                SettingsClickableItem(title = "Privacy Settings", onClick = { showPrivacyDialog = true })
                SettingsClickableItem(title = "Help & Support", onClick = { showSupportDialog = true })
            }
            
            item {
                Spacer(modifier = Modifier.height(48.dp))
                Text(
                    text = "Riri Version 1.0.0",
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                    style = MaterialTheme.typography.labelSmall,
                    color = com.riri.app.ui.theme.MutedText
                )
                Spacer(modifier = Modifier.height(100.dp))
            }
        }

        if (showPrivacyDialog) {
            AlertDialog(
                onDismissRequest = { showPrivacyDialog = false },
                containerColor = com.riri.app.ui.theme.HeaderBg,
                title = { Text("Privacy Secrets 🤫", color = Color.White, fontWeight = FontWeight.Bold) },
                text = { 
                    Text(
                        "Wag kang mag-alala, bestie. All your data stays on your phone. Offline-first tayo, so no creepy servers watching your tasks. Safe na safe tayo rito.",
                        color = com.riri.app.ui.theme.OffWhiteText
                    ) 
                },
                confirmButton = {
                    TextButton(onClick = { showPrivacyDialog = false }) {
                        Text("Got it!", color = com.riri.app.ui.theme.PrimaryViolet, fontWeight = FontWeight.Bold)
                    }
                }
            )
        }

        if (showSupportDialog) {
            AlertDialog(
                onDismissRequest = { showSupportDialog = false },
                containerColor = com.riri.app.ui.theme.HeaderBg,
                title = { Text("I'm here for you! ✨", color = Color.White, fontWeight = FontWeight.Bold) },
                text = { 
                    Column {
                        Text(
                            "May problem ba? If may bugs or suggestions ka, send ka lang ng screenshot/details sa support@riri.app. We gotchu!",
                            color = com.riri.app.ui.theme.OffWhiteText
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            "Don't worry, we'll fix it ASAP! 🛠️",
                            color = com.riri.app.ui.theme.AmberSecondary,
                            fontWeight = FontWeight.Bold
                        )
                    }
                },
                confirmButton = {
                    TextButton(onClick = { showSupportDialog = false }) {
                        Text("Keri na!", color = com.riri.app.ui.theme.PrimaryViolet, fontWeight = FontWeight.Bold)
                    }
                }
            )
        }

        if (showNameDialog) {
            AlertDialog(
                onDismissRequest = { showNameDialog = false },
                containerColor = com.riri.app.ui.theme.HeaderBg,
                title = { Text("Update Name ✨", color = Color.White, fontWeight = FontWeight.Bold) },
                text = {
                    OutlinedTextField(
                        value = tempName,
                        onValueChange = { tempName = it },
                        label = { Text("Anong itatawag ko sa'yo?") },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedBorderColor = com.riri.app.ui.theme.PrimaryViolet,
                            unfocusedBorderColor = com.riri.app.ui.theme.MutedText
                        )
                    )
                },
                confirmButton = {
                    TextButton(onClick = { 
                        viewModel.updateName(tempName)
                        showNameDialog = false 
                    }) {
                        Text("Save", color = com.riri.app.ui.theme.PrimaryViolet, fontWeight = FontWeight.Bold)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showNameDialog = false }) {
                        Text("Cancel", color = com.riri.app.ui.theme.MutedText)
                    }
                }
            )
        }
    }
}

@Composable
fun SettingsSectionTitle(title: String) {
    Text(
        text = title.uppercase(),
        style = MaterialTheme.typography.labelSmall,
        color = com.riri.app.ui.theme.MutedText,
        fontWeight = FontWeight.Bold,
        modifier = Modifier.padding(start = 8.dp, bottom = 12.dp)
    )
}

@Composable
fun PersonalitySelector(
    selectedMode: PersonalityMode,
    onModeSelected: (PersonalityMode) -> Unit
) {
    Column(
        modifier = Modifier
            .background(com.riri.app.ui.theme.SurfaceBg, RoundedCornerShape(16.dp))
            .padding(8.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        PersonalityMode.values().forEach { mode ->
            val isSelected = mode == selectedMode
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(if (isSelected) com.riri.app.ui.theme.PrimaryViolet.copy(alpha = 0.2f) else Color.Transparent)
                    .clickable { onModeSelected(mode) }
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = mode.name.lowercase().replaceFirstChar { it.uppercase() },
                    color = if (isSelected) Color.White else com.riri.app.ui.theme.OffWhiteText,
                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                    modifier = Modifier.weight(1f)
                )
                if (isSelected) {
                    Icon(
                        painter = painterResource(id = R.drawable.achievement), 
                        contentDescription = null, 
                        tint = Color.Unspecified, 
                        modifier = Modifier.size(24.dp)
                    )
                }
            }
        }
    }
}

@Composable
fun SettingsToggleItem(
    title: String,
    subtitle: String,
    isChecked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp)
            .background(com.riri.app.ui.theme.SurfaceBg, RoundedCornerShape(16.dp))
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(text = title, color = Color.White, fontWeight = FontWeight.Bold)
            Text(text = subtitle, color = com.riri.app.ui.theme.MutedText, fontSize = 12.sp)
        }
        Switch(
            checked = isChecked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(
                checkedThumbColor = Color.White,
                checkedTrackColor = com.riri.app.ui.theme.PrimaryViolet,
                uncheckedThumbColor = com.riri.app.ui.theme.MutedText,
                uncheckedTrackColor = com.riri.app.ui.theme.DeepCharcoalBg
            )
        )
    }
}

@Composable
fun SettingsStaticItem(
    title: String,
    subtitle: String,
    trailing: @Composable () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp)
            .background(com.riri.app.ui.theme.SurfaceBg, RoundedCornerShape(16.dp))
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(text = title, color = Color.White, fontWeight = FontWeight.Bold)
            Text(text = subtitle, color = com.riri.app.ui.theme.MutedText, fontSize = 12.sp)
        }
        trailing()
    }
}

@Composable
fun SettingsClickableItem(
    title: String,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp)
            .background(com.riri.app.ui.theme.SurfaceBg, RoundedCornerShape(16.dp))
            .clickable(onClick = onClick)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = title, color = Color.White, fontWeight = FontWeight.Medium, modifier = Modifier.weight(1f))
        Icon(Icons.Default.KeyboardArrowRight, contentDescription = null, tint = com.riri.app.ui.theme.MutedText)
    }
}
