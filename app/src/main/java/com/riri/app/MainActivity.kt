package com.riri.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Chat
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.BarChart
import androidx.compose.ui.unit.dp
import androidx.compose.material3.*
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.*
import com.riri.app.ui.screens.splash.SplashScreen
import com.riri.app.ui.screens.onboarding.OnboardingScreen
import com.riri.app.ui.screens.profile.*
import com.riri.app.ui.screens.settings.*
import com.riri.app.ui.screens.chat.*
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import android.Manifest
import android.os.Build
import com.riri.app.ui.screens.stats.ChaosReportScreen
import com.riri.app.ui.screens.stats.StatsViewModel
import com.riri.app.ui.theme.RiriTheme
import org.koin.androidx.viewmodel.ext.android.viewModel

class MainActivity : ComponentActivity() {
    
    private val dashboardViewModel: DashboardViewModel by viewModel()
    private val settingsViewModel: SettingsViewModel by viewModel()
    private val profileViewModel: ProfileViewModel by viewModel()
    private val chatViewModel: ChatViewModel by viewModel()
    private val statsViewModel: StatsViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            RiriTheme {
                val navController = rememberNavController()
                var showAddSheet by remember { mutableStateOf(false) }

                // Check if onboarding has been completed
                val userPrefsDataStore = org.koin.java.KoinJavaComponent.get<com.riri.app.data.preferences.UserPreferencesDataStore>(
                    com.riri.app.data.preferences.UserPreferencesDataStore::class.java
                )
                val hasCompletedOnboarding by userPrefsDataStore.hasCompletedOnboarding
                    .collectAsState(initial = false)

                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentDestination = navBackStackEntry?.destination
                val showBottomBar = currentDestination?.route in listOf("home", "chat", "profile", "settings")

                Scaffold(
                    modifier = Modifier.fillMaxSize(),
                    bottomBar = {
                        if (showBottomBar) {
                            NavigationBar(
                                containerColor = com.riri.app.ui.theme.HeaderBg,
                                contentColor = Color.White,
                                tonalElevation = 8.dp
                            ) {
                                val items = listOf(
                                    Triple("home", "Home", Icons.Default.Home),
                                    Triple("chat", "Chat", Icons.Default.Chat),
                                    Triple("chaos_report", "Report", Icons.Default.BarChart),
                                    Triple("profile", "Profile", Icons.Default.Person)
                                )
                                items.forEach { (route, label, icon) ->
                                    val selected = currentDestination?.hierarchy?.any { it.route == route } == true
                                    NavigationBarItem(
                                        icon = { Icon(icon, contentDescription = label) },
                                        label = { Text(label) },
                                        selected = selected,
                                        onClick = {
                                            navController.navigate(route) {
                                                popUpTo(navController.graph.findStartDestination().id) {
                                                    saveState = true
                                                }
                                                launchSingleTop = true
                                                restoreState = true
                                            }
                                        },
                                        colors = NavigationBarItemDefaults.colors(
                                            selectedIconColor = com.riri.app.ui.theme.PrimaryViolet,
                                            selectedTextColor = com.riri.app.ui.theme.PrimaryViolet,
                                            unselectedIconColor = com.riri.app.ui.theme.MutedText,
                                            unselectedTextColor = com.riri.app.ui.theme.MutedText,
                                            indicatorColor = com.riri.app.ui.theme.SurfaceBg
                                        )
                                    )
                                }
                            }
                        }
                    },
                    containerColor = MaterialTheme.colorScheme.background
                ) { padding ->
                    NavHost(
                        navController = navController, 
                        startDestination = "splash",
                        modifier = Modifier.padding(padding)
                    ) {
                        composable("splash") {
                            SplashScreen(
                                onSplashComplete = {
                                    val destination = if (hasCompletedOnboarding) "home" else "onboarding"
                                    navController.navigate(destination) {
                                        popUpTo("splash") { inclusive = true }
                                    }
                                }
                            )
                        }
                        composable("onboarding") {
                            val launcher = rememberLauncherForActivityResult(
                                contract = ActivityResultContracts.RequestPermission()
                            ) { _ ->
                                navController.navigate("home") {
                                    popUpTo("onboarding") { inclusive = true }
                                }
                            }

                            OnboardingScreen(
                                onLetsGoClick = {
                                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                                        launcher.launch(android.Manifest.permission.POST_NOTIFICATIONS)
                                    } else {
                                        navController.navigate("home") {
                                            popUpTo("onboarding") { inclusive = true }
                                        }
                                    }
                                }
                            )
                        }
                        compval stats by statsViewModel.stats.collectAsState()
                            ChaosReportScreen(
                                stats = statsn(
                                stats = null,
                                onBackClick = { navController.popBackStack() },
                                onShareClick = { /* Share logic */ }
                            )
                        }
                        composable("home") {
                            DashboardScreen(
                                uiStateFlow = dashboardViewModel.uiState,
                                onAddReminderClick = { showAddSheet = true },
                                onReminderClick = { dashboardViewModel.toggleReminderCompletion(it) },
                                onReminderToggle = { dashboardViewModel.toggleReminderCompletion(it) },
                                onReminderDelete = { dashboardViewModel.deleteReminder(it) },
                                onProfileClick = { navController.navigate("profile") },
                                onChatClick = { navController.navigate("chat") }
                            )
                        }
                        composable("chat") {
                            ChatScreen(
                                viewModel = chatViewModel,
                                onBackClick = { navController.popBackStack() }
                            )
                        }
                        composable("profile") {
                            ProfileScreen(
                                viewModel = profileViewModel,
                                onSettingsClick = { navController.navigate("settings") },
                                onShareClick = { profileViewModel.shareProfile() },
                                onChaosReportClick = { navController.navigate("chaos_report") }
                            )
                        }
                        composable("settings") {
                            SettingsScreen(
                                viewModel = settingsViewModel,
                                onBackClick = { navController.popBackStack() }
                            )
                        }
                    }

                    if (showAddSheet) {
                        AddReminderBottomSheet(
                            onDismiss = { showAddSheet = false },
                            onAddClick = { text, dueTime -> dashboardViewModel.addReminder(text, dueTime) }
                        )
                    }
                }
            }
        }
    }
}
