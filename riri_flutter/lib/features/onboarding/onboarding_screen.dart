import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/riri_theme.dart';
import '../../core/persistence/riri_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isDownloaded = false;
  Timer? _downloadTimer;

  @override
  void dispose() {
    _nameController.dispose();
    _downloadTimer?.cancel();
    super.dispose();
  }

  void _startLlmDownload() {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    _downloadTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        _downloadProgress += 0.05;
        if (_downloadProgress >= 1.0) {
          _downloadProgress = 1.0;
          _isDownloading = false;
          _isDownloaded = true;
          _downloadTimer?.cancel();
          _saveNameAndProceed();
        }
      });
    });
  }

  void _skipLlmDownload() {
    _downloadTimer?.cancel();
    setState(() {
      _isDownloading = false;
      _isDownloaded = false;
    });
    _saveNameAndProceed();
  }

  Future<void> _saveNameAndProceed() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      // 1. Write username cleanly through username provider which persists and emits
      await ref.read(usernameProvider.notifier).setUsername(name);

      // 2. Persist onboarding configs
      final prefs = SharedPreferencesAsync();
      await prefs.setBool('riri_onboarding_completed', true);
      await prefs.setBool('riri_use_full_llm', _isDownloaded);

      // 3. Mark completed to trigger reactive MaterialApp router update instantly
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
                  colors: [RiriTheme.primaryPurple.withOpacity(0.25), Colors.transparent],
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
                            color: RiriTheme.primaryPurple.withOpacity(0.15),
                          ),
                        ),
                        Image.asset(
                          'assets/stickers/Welcoming.png',
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
                            style: TextStyle(color: RiriTheme.secondaryAmber),
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

                    if (_isDownloading) ...[
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _downloadProgress,
                              minHeight: 10,
                              backgroundColor: RiriTheme.cardBg,
                              valueColor: const AlwaysStoppedAnimation<Color>(RiriTheme.primaryPurple),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Downloading Riri\'s brain... ${(_downloadProgress * 100).toInt()}%',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: RiriTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _skipLlmDownload,
                            child: const Text(
                              'Skip download, use fallback AI ✌️',
                              style: TextStyle(color: RiriTheme.textMuted, fontSize: 14),
                            ),
                          ),
                        ],
                      )
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isNameEmpty ? null : _saveNameAndProceed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RiriTheme.primaryPurple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: RiriTheme.cardBg.withOpacity(0.5),
                            disabledForegroundColor: RiriTheme.textMuted,
                            elevation: 8,
                            shadowColor: RiriTheme.primaryPurple.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            _isDownloaded ? 'Let\'s Go! 🚀' : 'Start with Lite AI ✨',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (!_isDownloaded) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: isNameEmpty ? null : _startLlmDownload,
                          child: const Text(
                            'Or download Full LLM (Recommended) 🧠',
                            style: TextStyle(
                              color: RiriTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ]
                    ],
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
