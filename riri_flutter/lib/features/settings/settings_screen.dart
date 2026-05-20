import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/persistence/riri_providers.dart';
import '../../theme/riri_theme.dart';
import 'persona_card_selector.dart';

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
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: RiriTheme.primaryPurple)),
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
            child: const Text('I-save 💾', style: TextStyle(color: RiriTheme.primaryPurple)),
          ),
        ],
      ),
    );
  }

  /// Shows premium secure Gemini API key config dialog
  void _showApiKeyDialog(BuildContext context, WidgetRef ref, String currentKey) {
    final controller = TextEditingController(text: currentKey);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: RiriTheme.cardBg,
        title: const Text('Gemini API Key 🔑', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ipasok ang iyong Gemini API key para ma-activate ang premium AI companion at dynamic Taglish chika. Mag-fallback sa local heuristics kapag walang key.',
              style: TextStyle(color: RiriTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'I-paste ang AIzaSy key...',
                hintStyle: TextStyle(color: RiriTheme.textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2F2F4A))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: RiriTheme.primaryPurple)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bansalan', style: TextStyle(color: RiriTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final newKey = controller.text.trim();
              ref.read(geminiApiKeyProvider.notifier).setApiKey(newKey);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(newKey.isEmpty 
                      ? 'Naka-set na sa Lite AI fallback engine.' 
                      : 'Premium Gemini AI brain activated! 🧠⚡'),
                  backgroundColor: RiriTheme.primaryPurple,
                ),
              );
            },
            child: const Text('I-save 💾', style: TextStyle(color: RiriTheme.primaryPurple)),
          ),
        ],
      ),
    );
  }

  /// Shows database restoration paste text dialog
  void _showRestoreDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: RiriTheme.cardBg,
        title: const Text('I-restore ang Data? 📥', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'I-paste ang iyong JSON backup string sa ibaba. MAG-INGAT: Mapapalitan ang lahat ng kasalukuyang tasks at chat history!',
              style: TextStyle(color: RiriTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'I-paste ang backup JSON dito...',
                hintStyle: TextStyle(color: RiriTheme.textMuted),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2F2F4A))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: RiriTheme.primaryPurple)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Bansalan', style: TextStyle(color: RiriTheme.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              final jsonStr = controller.text.trim();
              if (jsonStr.isEmpty) return;
              
              final success = await ref.read(repositoryProvider).importDataFromJson(jsonStr);
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success 
                      ? 'Matagumpay na na-restore ang iyong data! 📥🎉' 
                      : 'Error: Invalid backup JSON pattern. ❌'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('I-restore 📥', style: TextStyle(color: Colors.redAccent)),
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
    final geminiApiKey = ref.watch(geminiApiKeyProvider);
    final activeEngine = ref.watch(activeAIEngineProvider);

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
                
                PersonaCardSelector(
                  selectedMode: currentMode,
                  onPersonaSelected: (mode) {
                    ref.read(personalityModeProvider.notifier).setPersonalityMode(mode);
                  },
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
                        trailing: const Icon(Icons.edit, color: RiriTheme.primaryPurple, size: 20),
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
                        activeThumbColor: RiriTheme.primaryPurple,
                        onChanged: (value) {
                          ref.read(notificationsEnabledProvider.notifier).setNotificationsEnabled(value);
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                      const Divider(color: Color(0xFF2F2F4A), height: 1),

                      // Gemini API Key Config Tile
                      ListTile(
                        onTap: () => _showApiKeyDialog(context, ref, geminiApiKey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: const Text(
                          'Gemini API Key 🔑',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Brain: $activeEngine\n${geminiApiKey.isEmpty ? "Hindi naka-set. Naka-enable ang fallback AI heuristics." : "Naka-securely save ang API key sa device."}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        trailing: const Icon(Icons.vpn_key, color: RiriTheme.primaryPurple, size: 20),
                      ),
                      const Divider(color: Color(0xFF2F2F4A), height: 1),

                      // Backup Data (Clipboard)
                      ListTile(
                        onTap: () async {
                          try {
                            final backupJson = await ref.read(repositoryProvider).exportDataAsJson();
                            await Clipboard.setData(ClipboardData(text: backupJson));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Naka-copy na sa clipboard ang backup! 📋💾'),
                                  backgroundColor: RiriTheme.primaryPurple,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error sa backup: $e ❌'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: const Text(
                          'Backup Data (Copy) 📋',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Kopyahin ang lahat ng task at chat logs sa iyong clipboard bilang backup JSON.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        trailing: const Icon(Icons.copy, color: RiriTheme.primaryPurple, size: 20),
                      ),
                      const Divider(color: Color(0xFF2F2F4A), height: 1),

                      // Restore Data (Paste)
                      ListTile(
                        onTap: () => _showRestoreDialog(context, ref),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: const Text(
                          'Restore Data (Paste) 📥',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'I-import at i-restore ang task at chat history mula sa isang valid backup.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        trailing: const Icon(Icons.settings_backup_restore, color: RiriTheme.primaryPurple, size: 20),
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
