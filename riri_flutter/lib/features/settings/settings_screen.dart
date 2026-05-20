import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/persistence/riri_providers.dart';
import '../../core/notifications/personas.dart';
import '../../theme/riri_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Shows premium edit nickname dialog
  void _showNicknameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: RiriTheme.cardBg,
        title: const Text('Baguhin ang Pangalan? 👋', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Ipasok ang bagong pangalan...',
            hintStyle: TextStyle(color: RiriTheme.textMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2F2F4A))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: RiriTheme.secondaryAmber)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Wag na', style: TextStyle(color: RiriTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(usernameProvider.notifier).setUsername(newName);
              }
              Navigator.pop(context);
            },
            child: const Text('I-save 💾', style: TextStyle(color: RiriTheme.secondaryAmber)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentMode = ref.watch(personalityModeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final username = ref.watch(usernameProvider);

    return Scaffold(
      backgroundColor: RiriTheme.darkBg,
      appBar: AppBar(
        title: const Text('App Settings ⚙️'),
      ),
      body: Stack(
        children: [
          // Background top glow gradient for visual consistency
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [RiriTheme.primaryPurple.withValues(alpha: 0.15), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Riri Personality Selector
                Text(
                  'RIRI PERSONALITY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: RiriTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Stunning Redirect Banner Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [RiriTheme.primaryPurple.withValues(alpha: 0.4), RiriTheme.hotPink.withValues(alpha: 0.4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: RiriTheme.primaryPurple.withValues(alpha: 0.6), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Riri Personas 🎭',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Kasalukuyang naka-set sa ${PersonaConfig.get(currentMode).name} mode. Tap to adjust your nags and tones!',
                              style: const TextStyle(
                                fontSize: 12,
                                color: RiriTheme.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Route to Tab index 1
                          ref.read(tabIndexProvider.notifier).setTab(1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RiriTheme.hotPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'View 🎭',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Section 2: Preferences & System
                Text(
                  'PREFERENCES & SYSTEM',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: RiriTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: RiriTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2F2F4A), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Edit Nickname Tile
                      ListTile(
                        onTap: () => _showNicknameDialog(context, ref, username),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: const Text(
                          'Nickname Display 👋',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          username.trim().isEmpty 
                              ? 'Kasalukuyan: Walang pangalan. I-update para sa mas personal na chika.'
                              : 'Kasalukuyan: $username. I-update para sa mas personal na chika.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        trailing: const Icon(Icons.edit, color: RiriTheme.secondaryAmber, size: 20),
                      ),
                      const Divider(color: Color(0xFF2F2F4A), height: 1),

                      // Notifications Switch
                      SwitchListTile(
                        title: const Text(
                          'Personality Notifications 🔔',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Allow Riri to send witty notifications and nagging reminders in Taglish.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        value: notificationsEnabled,
                        activeThumbColor: RiriTheme.secondaryAmber,
                        onChanged: (value) {
                          ref.read(notificationsEnabledProvider.notifier).setNotificationsEnabled(value);
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Subtle version log at bottom
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Riri cross-platform v1.0.0',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: RiriTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Made with 💜 in the Philippines',
                        style: TextStyle(color: RiriTheme.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
