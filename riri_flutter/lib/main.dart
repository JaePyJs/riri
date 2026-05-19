import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/riri_theme.dart';
import 'core/persistence/riri_database.dart';
import 'core/persistence/riri_repository.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/reminders/add_reminder_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pre-load preferences using non-blocking SharedPreferencesAsync to determine starting route
  final prefs = SharedPreferencesAsync();
  final onboardingCompleted = await prefs.getBool('riri_onboarding_completed') ?? false;
  final username = await prefs.getString('riri_username') ?? 'Bestie';

  final database = RiriDatabase();

  runApp(RiriApp(
    database: database,
    onboardingCompleted: onboardingCompleted,
    username: username,
  ));
}

class RiriApp extends StatelessWidget {
  final RiriDatabase database;
  final bool onboardingCompleted;
  final String username;

  const RiriApp({
    Key? key,
    required this.database,
    required this.onboardingCompleted,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riri',
      debugShowCheckedModeBanner: false,
      theme: RiriTheme.darkThemeData,
      home: onboardingCompleted
          ? RiriAppShell(database: database, initialUsername: username)
          : NavigationController(database: database, initialUsername: username),
    );
  }
}

class NavigationController extends StatefulWidget {
  final RiriDatabase database;
  final String initialUsername;
  const NavigationController({Key? key, required this.database, required this.initialUsername}) : super(key: key);

  @override
  _NavigationControllerState createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  bool _completed = false;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _username = widget.initialUsername;
  }

  void _onLetsGo() async {
    final prefs = SharedPreferencesAsync();
    final username = await prefs.getString('riri_username') ?? 'Bestie';
    setState(() {
      _username = username;
      _completed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return RiriAppShell(database: widget.database, initialUsername: _username);
    }
    return OnboardingScreen(onLetsGoClick: _onLetsGo);
  }
}

class RiriAppShell extends StatefulWidget {
  final RiriDatabase database;
  final String initialUsername;

  const RiriAppShell({Key? key, required this.database, required this.initialUsername}) : super(key: key);

  @override
  _RiriAppShellState createState() => _RiriAppShellState();
}

class _RiriAppShellState extends State<RiriAppShell> {
  late final RiriRepository _repository;
  int _currentTabIndex = 0;
  String _username = '';
  List<RiriReminder> _remindersList = [];
  StreamSubscription<List<RiriReminder>>? _remindersSubscription;

  @override
  void initState() {
    super.initState();
    _repository = RiriRepository(database: widget.database);
    _username = widget.initialUsername;
    _remindersList = _repository.currentReminders;

    // React to changes in database reminders
    _remindersSubscription = _repository.remindersStream.listen((list) {
      if (mounted) {
        setState(() {
          _remindersList = list;
        });
      }
    });
  }

  @override
  void dispose() {
    _remindersSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }

  void _toggleReminderCompletion(int id) {
    _repository.toggleReminderCompletion(id);
  }

  void _deleteReminder(int id) {
    _repository.deleteReminder(id);
  }

  void _showAddReminderBottomSheet() {
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
            _repository.addReminder(
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

  void _refreshSettings() async {
    final prefs = SharedPreferencesAsync();
    final username = await prefs.getString('riri_username') ?? 'Bestie';
    if (mounted) {
      setState(() {
        _username = username;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      DashboardScreen(
        username: _username,
        reminders: _remindersList,
        onToggleCompletion: _toggleReminderCompletion,
        onDeleteReminder: _deleteReminder,
        onAddReminderTap: _showAddReminderBottomSheet,
      ),
      ChatScreen(repository: _repository),
      SettingsScreen(
        repository: _repository,
        onSettingsUpdated: _refreshSettings,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
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
