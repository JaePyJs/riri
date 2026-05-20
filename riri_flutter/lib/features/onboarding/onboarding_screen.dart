import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/riri_theme.dart';
import '../../core/persistence/riri_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late final AnimationController _mascotController;
  late final Animation<Offset> _mascotAnimation;

  @override
  void initState() {
    super.initState();
    _mascotController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _mascotAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.05),
    ).animate(CurvedAnimation(
      parent: _mascotController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mascotController.dispose();
    super.dispose();
  }

  Future<void> _saveNameAndProceed() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      // 1. Write username cleanly through username provider which persists and emits
      await ref.read(usernameProvider.notifier).setUsername(name);

      // 2. Persist onboarding configs
      final prefs = SharedPreferencesAsync();
      await prefs.setBool('riri_onboarding_completed', true);

      // 3. Mark completed to trigger reactive router update instantly
      ref.read(onboardingCompletedProvider.notifier).complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNameEmpty = _nameController.text.trim().isEmpty;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: RiriTheme.darkBg,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [RiriTheme.primaryPurple.withValues(alpha: 0.25), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: RiriTheme.primaryPurple.withValues(alpha: 0.15),
                          ),
                        ),
                        SlideTransition(
                          position: _mascotAnimation,
                          child: Image.asset(
                            'assets/stickers/Welcoming.webp',
                            width: 180,
                            height: 180,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RiriTheme.brandGradient,
                                ),
                                child: const Icon(Icons.star, size: 60, color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.displayLarge,
                        children: const [
                          TextSpan(text: 'Welcome to '),
                          TextSpan(
                            text: 'Riri',
                            style: TextStyle(color: RiriTheme.hotPink),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Alam mo na dapat. Gawin mo na.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: RiriTheme.offWhite,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'First off, ano itatawag ko sa\'yo? ✨',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: RiriTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        color: RiriTheme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2F2F4A), width: 1.5),
                      ),
                      child: TextField(
                        controller: _nameController,
                        onChanged: (text) => setState(() {}),
                        textAlign: TextAlign.left,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter your nickname...',
                          hintStyle: TextStyle(color: RiriTheme.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          prefixIcon: Icon(Icons.person, color: RiriTheme.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isNameEmpty ? null : _saveNameAndProceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RiriTheme.primaryPurple,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: RiriTheme.cardBg.withValues(alpha: 0.5),
                          disabledForegroundColor: RiriTheme.textMuted,
                          elevation: 8,
                          shadowColor: RiriTheme.primaryPurple.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Mag-start na tayo! 🚀',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
