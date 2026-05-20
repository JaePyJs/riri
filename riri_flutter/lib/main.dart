import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'theme/riri_theme.dart';
import 'core/persistence/riri_database.dart';
import 'core/persistence/riri_providers.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final database = RiriDatabase();

  runApp(
    ProviderScope(
      overrides: [
        // Fix database disposal leak by registering onDispose inside overrideWith
        databaseProvider.overrideWith((ref) {
          ref.onDispose(() => database.close());
          return database;
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
    final onboardingFuture = ref.watch(onboardingCompletedFutureProvider);

    final mainScreen = onboardingFuture.when(
      data: (completed) {
        // Fallback to the provider if we've completed onboarding during session
        final isActuallyCompleted = completed || ref.watch(onboardingCompletedProvider);
        return isActuallyCompleted ? const RiriAppShell() : const OnboardingScreen();
      },
      loading: () => const SplashScreen(),
      error: (error, _) => const OnboardingScreen(),
    );

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
                color: Colors.black.withValues(alpha: 0.6),
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
      body: _FadeIndexedStack(
        index: currentTabIndex,
        children: [
          TickerMode(enabled: currentTabIndex == 0, child: const DashboardScreen()),
          TickerMode(enabled: currentTabIndex == 1, child: const ChatTab()),
          TickerMode(enabled: currentTabIndex == 2, child: const SettingsTab()),
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

class _FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const _FadeIndexedStack({
    required this.index,
    required this.children,
  });

  @override
  State<_FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<_FadeIndexedStack> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _FadeIndexedStack oldWidget) {
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
      child: IndexedStack(
        index: widget.index,
        children: widget.children,
      ),
    );
  }
}

