import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'theme/riri_theme.dart';
import 'core/persistence/riri_database.dart';
import 'core/persistence/riri_providers.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/personas_screen.dart';

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
          return OnboardingCompletedNotifier(onboardingCompleted);
        }),
      ],
      child: const RiriApp(),
    ),
  );
}

class RiriApp extends ConsumerWidget {
  const RiriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);

    final mainScreen = onboardingCompleted
        ? const RiriAppShell()
        : const OnboardingScreen();

    return MaterialApp(
      title: 'Riri',
      debugShowCheckedModeBanner: false,
      theme: RiriTheme.darkThemeData,
      home: kIsWeb ? _WebShell(child: mainScreen) : mainScreen,
    );
  }
}

class _WebShell extends StatelessWidget {
  final Widget child;

  const _WebShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0C0B10), // Elegant deep OLED-grade backdrop
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          constraints: const BoxConstraints(maxWidth: 430, maxHeight: 900),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF22202C),
                  width: 8,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                borderRadius: BorderRadius.circular(36),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class RiriAppShell extends ConsumerWidget {
  const RiriAppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTabIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      body: AnimatedIndexedStack(
        index: currentTabIndex,
        children: const [
          DashboardScreen(),
          PersonaSelectorScreen(),
          ChatTab(),
          SettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTabIndex,
        onDestinationSelected: (index) {
          ref.read(tabIndexProvider.notifier).setTab(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.mood_outlined),
            selectedIcon: Icon(Icons.mood),
            label: 'Personas',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Riri Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class ChatTab extends ConsumerWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ChatScreen();
  }
}

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SettingsScreen();
  }
}

class AnimatedIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const AnimatedIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<AnimatedIndexedStack> createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.98, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        ),
        child: IndexedStack(
          index: widget.index,
          children: widget.children,
        ),
      ),
    );
  }
}
