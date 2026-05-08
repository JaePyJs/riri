package com.riri.app.ui.screens.dashboard

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import android.net.Uri
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.riri.app.R
import com.riri.app.ui.theme.RiriGradient
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import org.koin.androidx.compose.koinViewModel
import java.text.SimpleDateFormat
import java.util.*

class AddReminderViewModel(
    private val whisperEngine: com.riri.app.core.ai.WhisperEngine
) : ViewModel() {
    private val _isRecording = MutableStateFlow(false)
    val isRecording = _isRecording.asStateFlow()

    fun startVoiceRecording(onTranscriptionReceived: (String) -> Unit) {
        viewModelScope.launch {
            _isRecording.value = true
            // Recording logic...
            kotlinx.coroutines.delay(1500)
            _isRecording.value = false
            onTranscriptionReceived("Bili ng milk mamaya")
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddReminderBottomSheet(
    onDismiss: () -> Unit,
    onAddClick: (String, Long) -> Unit,
    viewModel: AddReminderViewModel = koinViewModel()
) {
    var text by remember { mutableStateOf("") }
    val isRecording by viewModel.isRecording.collectAsState()
    val context = LocalContext.current
    
    val calendar = remember { Calendar.getInstance() }
    var selectedDateTime by remember { mutableStateOf(calendar.timeInMillis + 3600000) } // Default +1hr
    
    var showDatePicker by remember { mutableStateOf(false) }
    var showTimePicker by remember { mutableStateOf(false) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = com.riri.app.ui.theme.HeaderBg,
        dragHandle = {
            Box(
                modifier = Modifier
                    .padding(vertical = 12.dp)
                    .size(width = 48.dp, height = 6.dp)
                    .background(com.riri.app.ui.theme.SurfaceBg, RoundedCornerShape(3.dp))
            )
        },
        shape = RoundedCornerShape(topStart = 32.dp, topEnd = 32.dp)
    ) {
        Column(
            modifier = Modifier
                .padding(24.dp)
                .fillMaxWidth()
        ) {
                Text(
                    text = "New Reminder",
                    style = MaterialTheme.typography.headlineSmall,
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )

            Spacer(modifier = Modifier.height(32.dp))

            var selectedImageUri by remember { mutableStateOf<Uri?>(null) }
            val launcher = rememberLauncherForActivityResult(
                contract = ActivityResultContracts.GetContent()
            ) { uri: Uri? ->
                selectedImageUri = uri
            }

            TextField(
                value = text,
                onValueChange = { text = it },
                modifier = Modifier
                    .fillMaxWidth()
                    .background(com.riri.app.ui.theme.SurfaceBg, RoundedCornerShape(16.dp)),
                placeholder = { Text("Ano gagawin natin?", color = com.riri.app.ui.theme.MutedText) },
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
                keyboardActions = KeyboardActions(
                    onDone = {
                        if (text.isNotBlank()) {
                            onAddClick(text, selectedDateTime)
                            onDismiss()
                        }
                    }
                ),
                trailingIcon = {
                    Row {
                        IconButton(
                            onClick = { 
                                viewModel.startVoiceRecording { transcription ->
                                    text = transcription
                                }
                            }
                        ) {
                            Icon(
                                painter = painterResource(id = if (isRecording) R.drawable.thinking else R.drawable.welcoming),
                                contentDescription = "Voice",
                                modifier = Modifier.size(24.dp),
                                tint = if (isRecording) com.riri.app.ui.theme.PrimaryViolet else com.riri.app.ui.theme.MutedText
                            )
                        }
                        IconButton(
                            onClick = { launcher.launch("image/*") }
                        ) {
                            Icon(
                                painter = painterResource(id = com.riri.app.R.drawable.achievement), 
                                contentDescription = "Add Image",
                                modifier = Modifier.size(24.dp),
                                tint = if (selectedImageUri != null) com.riri.app.ui.theme.AmberSecondary else com.riri.app.ui.theme.MutedText
                            )
                        }
                    }
                },
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent,
                    unfocusedContainerColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                    cursorColor = Color.White,
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White
                ),
                shape = RoundedCornerShape(16.dp)
            )

            if (selectedImageUri != null) {
                Spacer(modifier = Modifier.height(12.dp))
                Box(modifier = Modifier.size(60.dp).clip(RoundedCornerShape(8.dp))) {
                    AsyncImage(
                        model = selectedImageUri,
                        contentDescription = null,
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                    IconButton(
                        onClick = { selectedImageUri = null },
                        modifier = Modifier.align(Alignment.TopEnd).size(16.dp).background(Color.Black.copy(alpha = 0.5f), CircleShape)
                    ) {
                        Text("×", color = Color.White, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                val dateFormat = remember { SimpleDateFormat("MMM dd", Locale.getDefault()) }
                val timeFormat = remember { SimpleDateFormat("hh:mm a", Locale.getDefault()) }

                Button(
                    onClick = { showDatePicker = true },
                    modifier = Modifier.weight(1f).height(56.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = com.riri.app.ui.theme.SurfaceBg),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Icon(
                        imageVector = androidx.compose.material.icons.Icons.Default.DateRange, 
                        contentDescription = null, 
                        tint = com.riri.app.ui.theme.MutedText
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(dateFormat.format(Date(selectedDateTime)), color = com.riri.app.ui.theme.MutedText, fontWeight = FontWeight.Medium)
                }
                
                Button(
                    onClick = { showTimePicker = true },
                    modifier = Modifier.weight(1f).height(56.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = com.riri.app.ui.theme.SurfaceBg),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Icon(
                        painter = painterResource(id = R.drawable.inactive), 
                        contentDescription = null, 
                        tint = com.riri.app.ui.theme.MutedText, 
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(timeFormat.format(Date(selectedDateTime)), color = com.riri.app.ui.theme.MutedText, fontWeight = FontWeight.Medium)
                }
            }

            Spacer(modifier = Modifier.height(48.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                Button(
                    onClick = onDismiss,
                    modifier = Modifier.weight(1f).height(56.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = com.riri.app.ui.theme.SurfaceBg),
                    shape = RoundedCornerShape(28.dp)
                ) {
                    Text("Cancel", color = Color.White, fontWeight = FontWeight.Bold)
                }
                
                Button(
                    onClick = { 
                        if (text.isNotBlank()) {
                            onAddClick(text, selectedDateTime)
                            onDismiss()
                        }
                    },
                    modifier = Modifier.weight(2f).height(56.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent),
                    shape = RoundedCornerShape(28.dp),
                    contentPadding = PaddingValues()
                ) {
                    Box(
                        modifier = Modifier.fillMaxSize().background(com.riri.app.ui.theme.RiriGradient),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("Add Reminder", color = Color.White, fontWeight = FontWeight.Bold)
                    }
                }
            }

            if (showDatePicker) {
                val datePickerState = rememberDatePickerState(
                    initialSelectedDateMillis = selectedDateTime
                )
                DatePickerDialog(
                    onDismissRequest = { showDatePicker = false },
                    confirmButton = {
                        TextButton(onClick = {
                            datePickerState.selectedDateMillis?.let {
                                val newCal = Calendar.getInstance().apply { timeInMillis = it }
                                val oldCal = Calendar.getInstance().apply { timeInMillis = selectedDateTime }
                                newCal.set(Calendar.HOUR_OF_DAY, oldCal.get(Calendar.HOUR_OF_DAY))
                                newCal.set(Calendar.MINUTE, oldCal.get(Calendar.MINUTE))
                                selectedDateTime = newCal.timeInMillis
                            }
                            showDatePicker = false
                        }) { Text("OK") }
                    }
                ) {
                    DatePicker(state = datePickerState)
                }
            }

            if (showTimePicker) {
                val timePickerState = rememberTimePickerState(
                    initialHour = Calendar.getInstance().apply { timeInMillis = selectedDateTime }.get(Calendar.HOUR_OF_DAY),
                    initialMinute = Calendar.getInstance().apply { timeInMillis = selectedDateTime }.get(Calendar.MINUTE)
                )
                AlertDialog(
                    onDismissRequest = { showTimePicker = false },
                    confirmButton = {
                        TextButton(onClick = {
                            val cal = Calendar.getInstance().apply { timeInMillis = selectedDateTime }
                            cal.set(Calendar.HOUR_OF_DAY, timePickerState.hour)
                            cal.set(Calendar.MINUTE, timePickerState.minute)
                            selectedDateTime = cal.timeInMillis
                            showTimePicker = false
                        }) { Text("OK") }
                    },
                    text = { TimePicker(state = timePickerState) }
                )
            }
            
            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}
