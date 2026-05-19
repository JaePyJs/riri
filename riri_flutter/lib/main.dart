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
          : const NavigationController(),
    );
  }
}

class NavigationController extends ConsumerWidget {
  const NavigationController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(repositoryProvider);

    void onLetsGo() async {
      final prefs = SharedPreferencesAsync();
      final username = await prefs.getString('riri_username') ?? 'Bestie';
      
      // Update Providers cleanly through standard Notifier methods
      ref.read(usernameProvider.notifier).setUsername(username);
      ref.read(onboardingCompletedProvider.notifier).complete();
    }

    return OnboardingScreen(onLetsGoClick: onLetsGo);
  }
}

class RiriAppShell extends ConsumerWidget {
  const RiriAppShell({Key? key}) : super(key: key);

  void _showAddReminderBottomSheet(BuildContext context, RiriRepository repository) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddReminderSheet(
          onSave: ({
            required String title,
            String? description,
            required ReminderCategory category,
            required DateTime dueDateTime,
          }) {
            repository.addReminder(
              title: title,
              description: description,
              category: category,
              dueDateTime: dueDateTime,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(repositoryProvider);
    final remindersAsync = ref.watch(remindersStreamProvider);
    
    // Provide dynamic async values with standard repositories fallbacks to prevent initial page flashing
    final remindersList = remindersAsync.value ?? repository.currentReminders;
    final username = ref.watch(usernameProvider);
    final currentTabIndex = ref.watch(tabIndexProvider);

    final List<Widget> tabs = [
      DashboardScreen(
        username: username,
        reminders: remindersList,
        onToggleCompletion: (id) => repository.toggleReminderCompletion(id),
        onDeleteReminder: (id) => repository.deleteReminder(id),
        onAddReminderTap: () => _showAddReminderBottomSheet(context, repository),
      ),
      ChatScreen(repository: repository),
      SettingsScreen(
        repository: repository,
        onSettingsUpdated: () {
          ref.read(usernameProvider.notifier).loadUsername();
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentTabIndex,
        children: tabs,
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
