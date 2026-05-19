import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/riri_theme.dart';
import 'core/persistence/riri_database.dart';
import 'core/persistence/riri_repository.dart';
import 'core/persistence/riri_providers.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/reminders/add_reminder_sheet.dart';
import 'core/ai/ai_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pre-load preference state dynamically to override Provider state on boot
  final database = RiriDatabase();
  final prefs = SharedPreferencesAsync();
  final onboardingCompleted = await prefs.getBool('riri_onboarding_completed') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        // Fix database disposal leak by registering onDispose inside overrideWith
        databaseProvider.overrideWith((ref) {
          ref.onDispose(() => database.close());
          return database;
        }),
        onboardingCompletedProvider.overrideWith(() {
          return OnboardingCompletedNotifier()..setCompleted(onboardingCompleted);
        }),
      ],
      child: const RiriApp(),
    ),
  );
}

class RiriApp extends ConsumerWidget {
  const RiriApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);

    return MaterialApp(
      title: 'Riri',
      debugShowCheckedModeBanner: false,
      theme: RiriTheme.darkThemeData,
      home: onboardingCompleted
          ? const RiriAppShell()
          : const OnboardingScreen(),
    );
  }
}

class RiriAppShell extends ConsumerWidget {
  const RiriAppShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTabIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentTabIndex,
        children: const [
          DashboardScreen(),
          ChatTab(),
          SettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex,
        onTap: (index) {
          // Trigger type-safe tab mutation method instead of direct state assignment
          ref.read(tabIndexProvider.notifier).setTab(index);
        },
        backgroundColor: RiriTheme.cardBg,
        selectedItemColor: RiriTheme.secondaryAmber,
        unselectedItemColor: RiriTheme.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            activeIcon: Icon(Icons.calendar_month, color: RiriTheme.secondaryAmber),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble, color: RiriTheme.secondaryAmber),
            label: 'Riri Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings, color: RiriTheme.secondaryAmber),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class ChatTab extends ConsumerWidget {
  const ChatTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ChatScreen();
  }
}

class SettingsTab extends ConsumerWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SettingsScreen();
  }
}
