import 'package:flutter/material.dart';
import '../../core/ai/ai_models.dart';
import '../../core/persistence/riri_repository.dart';
import '../../core/notifications/personality_copy.dart';
import '../../theme/riri_theme.dart';

class SettingsScreen extends StatefulWidget {
  final RiriRepository repository;
  final VoidCallback onSettingsUpdated;

  const SettingsScreen({
    Key? key,
    required this.repository,
    required this.onSettingsUpdated,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PersonalityMode _currentMode = PersonalityMode.bestie;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final mode = await widget.repository.getPersonalityMode();
    final notifs = await widget.repository.getNotificationsEnabled();
    setState(() {
      _currentMode = mode;
      _notificationsEnabled = notifs;
    });
  }

  Future<void> _updatePersonality(PersonalityMode mode) async {
    await widget.repository.setPersonalityMode(mode);
    setState(() {
      _currentMode = mode;
    });
    widget.onSettingsUpdated();
  }

  Future<void> _updateNotifications(bool value) async {
    await widget.repository.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: RiriTheme.darkBg,
      appBar: AppBar(
        backgroundColor: RiriTheme.cardBg,
        title: const Text(
          'App Settings ⚙️',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Riri Personality Selector
            const Text(
              'RIRI PERSONALITY',
              style: TextStyle(
                color: RiriTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: RiriTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2F2F4A), width: 1.2),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: PersonalityMode.values.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Color(0xFF2F2F4A), height: 1),
                itemBuilder: (context, index) {
                  final mode = PersonalityMode.values[index];
                  final isSelected = _currentMode == mode;

                  return InkWell(
                    onTap: () => _updatePersonality(mode),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              mode.displayLabel,
                              style: TextStyle(
                                color: isSelected ? Colors.white : RiriTheme.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: RiriTheme.secondaryAmber)
                          else
                            const Icon(Icons.circle_outlined, color: RiriTheme.textMuted),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Section 2: Notifications Toggles
            const Text(
              'PREFERENCES & SYSTEM',
              style: TextStyle(
                color: RiriTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: RiriTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2F2F4A), width: 1.2),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Personality Notifications 🔔',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Allow Riri to send witty notifications and nagging reminders in Taglish.',
                      style: TextStyle(color: RiriTheme.textSecondary, fontSize: 12),
                    ),
                    value: _notificationsEnabled,
                    activeColor: RiriTheme.secondaryAmber,
                    onChanged: _updateNotifications,
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
    );
  }
}
