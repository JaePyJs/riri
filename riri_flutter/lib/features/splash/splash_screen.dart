import 'package:flutter/material.dart';
import '../../theme/riri_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RiriTheme.darkBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [RiriTheme.primaryPurple.withValues(alpha: 0.3), RiriTheme.darkBg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RiriTheme.brandGradient,
                ),
                child: const Icon(Icons.star, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(RiriTheme.primaryPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
