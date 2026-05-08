package com.riri.app.ui.screens.chat

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Send
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
import com.riri.app.data.db.entities.ChatMessage
import com.riri.app.ui.components.RiriAssetMapper
import com.riri.app.ui.components.DashboardState
import com.riri.app.ui.theme.PrimaryViolet

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatScreen(
    viewModel: ChatViewModel,
    onBackClick: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    var inputText by remember { mutableStateOf("") }
    val listState = rememberLazyListState()

    // Scroll to bottom when new messages arrive
    LaunchedEffect(uiState.messages.size, uiState.isTyping) {
        if (uiState.messages.isNotEmpty() || uiState.isTyping) {
            listState.animateScrollToItem(
                if (uiState.isTyping) uiState.messages.size else uiState.messages.size - 1
            )
        }
    }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { 
                    Text(
                        "Riri Chat", 
                        color = Color.White, 
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                },
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
        containerColor = com.riri.app.ui.theme.DeepCharcoalBg,
        bottomBar = {
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .imePadding(),
                color = com.riri.app.ui.theme.HeaderBg,
                shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
            ) {
                Row(
                    modifier = Modifier
                        .padding(horizontal = 16.dp, vertical = 12.dp)
                        .navigationBarsPadding(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    TextField(
                        value = inputText,
                        onValueChange = { inputText = it },
                        modifier = Modifier.weight(1f),
                        placeholder = { Text("Ask Riri anything...", color = com.riri.app.ui.theme.MutedText) },
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = com.riri.app.ui.theme.SurfaceBg,
                            unfocusedContainerColor = com.riri.app.ui.theme.SurfaceBg,
                            focusedIndicatorColor = Color.Transparent,
                            unfocusedIndicatorColor = Color.Transparent,
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        ),
                        shape = RoundedCornerShape(24.dp),
                        maxLines = 4
                    )
                    
                    Spacer(modifier = Modifier.width(12.dp))
                    
                    IconButton(
                        onClick = {
                            if (inputText.isNotBlank()) {
                                viewModel.sendMessage(inputText)
                                inputText = ""
                            }
                        },
                        modifier = Modifier
                            .background(com.riri.app.ui.theme.RiriGradient, CircleShape)
                            .size(48.dp)
                    ) {
                        Icon(Icons.Default.Send, contentDescription = "Send", tint = Color.White)
                    }
                }
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(
                    top = padding.calculateTopPadding(),
                    bottom = padding.calculateBottomPadding()
                )
        ) {
            LazyColumn(
                state = listState,
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                contentPadding = PaddingValues(
                    bottom = 16.dp,
                    start = 16.dp,
                    end = 16.dp,
                    top = 16.dp
                ),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                items(uiState.messages) { message ->
                    ChatBubble(message = message)
                }
                
                if (uiState.isTyping) {
                    item {
                        TypingIndicator()
                    }
                }
            }
        }
    }
}

@Composable
fun ChatBubble(message: ChatMessage) {
    val alignment = if (message.isUser) Alignment.CenterEnd else Alignment.CenterStart
    val bgColor = if (message.isUser) com.riri.app.ui.theme.PrimaryViolet else com.riri.app.ui.theme.SurfaceBg
    val shape = if (message.isUser) {
        RoundedCornerShape(topStart = 20.dp, topEnd = 4.dp, bottomStart = 20.dp, bottomEnd = 20.dp)
    } else {
        RoundedCornerShape(topStart = 4.dp, topEnd = 20.dp, bottomStart = 20.dp, bottomEnd = 20.dp)
    }

    Box(modifier = Modifier.fillMaxWidth(), contentAlignment = alignment) {
        Row(
            verticalAlignment = Alignment.Bottom,
            horizontalArrangement = if (message.isUser) Arrangement.End else Arrangement.Start
        ) {
            if (!message.isUser) {
                Image(
                    painter = painterResource(id = com.riri.app.R.drawable.thinking),
                    contentDescription = null,
                    modifier = Modifier.size(36.dp).clip(CircleShape)
                )
                Spacer(modifier = Modifier.width(10.dp)) // 8dp + 2dp extra padding
            }
            
            Surface(
                color = bgColor,
                shape = shape,
                modifier = Modifier.widthIn(max = 280.dp),
                border = if (!message.isUser) androidx.compose.foundation.BorderStroke(1.dp, com.riri.app.ui.theme.PrimaryViolet.copy(alpha = 0.3f)) else null
            ) {
                Text(
                    text = message.text,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
                    color = Color.White.copy(alpha = 1f),
                    fontSize = 15.sp,
                    lineHeight = 22.sp
                )
            }
        }
    }
}

@Composable
fun TypingIndicator() {
    Row(
        modifier = Modifier.padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Image(
            painter = painterResource(id = com.riri.app.R.drawable.thinking),
            contentDescription = null,
            modifier = Modifier.size(36.dp).clip(CircleShape)
        )
        Spacer(modifier = Modifier.width(10.dp))
        Box(
            modifier = Modifier
                .background(com.riri.app.ui.theme.SurfaceBg, RoundedCornerShape(20.dp))
                .padding(horizontal = 16.dp, vertical = 8.dp)
        ) {
            Text(
                "Riri is typing...", 
                color = Color.White.copy(alpha = 1f), 
                fontSize = 13.sp, 
                fontWeight = FontWeight.Medium
            )
        }
    }
}
