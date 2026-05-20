import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notifications/personality_copy.dart';
import '../../theme/riri_theme.dart';
import '../../features/dashboard/riri_asset_mapper.dart';
import 'riri_database.dart';
import 'riri_repository.dart';

/// Database singleton provider.
final databaseProvider = Provider<RiriDatabase>((ref) {
  final db = RiriDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Repository singleton provider injected with the database.
final repositoryProvider = Provider<RiriRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final repo = RiriRepository(database: db);
  ref.onDispose(() => repo.dispose());
  return repo;
});

/// Reactive stream provider broadcasting standard user reminders.
final remindersStreamProvider = StreamProvider<List<RiriReminder>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.remindersStream;
});

/// Modern Riverpod 2.x Notifier for Tab Index management.
class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    assert(index >= 0 && index <= 2, 'Tab index must be between 0 and 2');
    state = index;
  }
}

final tabIndexProvider = NotifierProvider<TabIndexNotifier, int>(() => TabIndexNotifier());

/// Modern Riverpod 2.x Notifier for Onboarding Completed state.
class OnboardingCompletedNotifier extends Notifier<bool> {
  final bool? initialValue;
  OnboardingCompletedNotifier([this.initialValue]);

  @override
  bool build() => initialValue ?? false;

  void complete() {
    state = true;
  }
  
  void setCompleted(bool completed) {
    state = completed;
  }
}

final onboardingCompletedProvider = NotifierProvider<OnboardingCompletedNotifier, bool>(() => OnboardingCompletedNotifier());

/// Modern Riverpod 2.x Notifier for Username management.
class UsernameNotifier extends Notifier<String> {
  @override
  String build() => '';

  Future<void> loadUsername() async {
    final prefs = SharedPreferencesAsync();
    final name = await prefs.getString('riri_username');
    if (name != null) {
      state = name;
    }
  }

  Future<void> setUsername(String name) async {
    final prefs = SharedPreferencesAsync();
    await prefs.setString('riri_username', name);
    state = name;
  }
}

final usernameProvider = NotifierProvider<UsernameNotifier, String>(() => UsernameNotifier());

/// Modern Riverpod 2.x Notifier for Personality Mode management.
class PersonalityModeNotifier extends Notifier<PersonalityMode> {
  @override
  PersonalityMode build() {
    loadPersonalityMode();
    return PersonalityMode.bestie;
  }

  Future<void> loadPersonalityMode() async {
    final repo = ref.read(repositoryProvider);
    final mode = await repo.getPersonalityMode();
    state = mode;
  }

  Future<void> setPersonalityMode(PersonalityMode mode) async {
    final repo = ref.read(repositoryProvider);
    await repo.setPersonalityMode(mode);
    state = mode;
  }
}

final personalityModeProvider = NotifierProvider<PersonalityModeNotifier, PersonalityMode>(() => PersonalityModeNotifier());

/// Modern Riverpod 2.x Notifier for Notifications Enabled state.
class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    loadNotificationsEnabled();
    return true;
  }

  Future<void> loadNotificationsEnabled() async {
    final repo = ref.read(repositoryProvider);
    final enabled = await repo.getNotificationsEnabled();
    state = enabled;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final repo = ref.read(repositoryProvider);
    await repo.setNotificationsEnabled(enabled);
    state = enabled;
  }
}

final notificationsEnabledProvider = NotifierProvider<NotificationsEnabledNotifier, bool>(() => NotificationsEnabledNotifier());

class ProcrastinationIndexData {
  final String label;      // "Proactive 👑", "Mild Slacker ☕", etc.
  final Color color;       // matching RiriTheme color
  final double avgSnooze;  // raw value for future use
  const ProcrastinationIndexData({
    required this.label,
    required this.color,
    required this.avgSnooze,
  });
}

final streakProvider = Provider<int>((ref) {
  final remindersAsync = ref.watch(remindersStreamProvider);
  return remindersAsync.maybeWhen(
    data: (reminders) {
      final completedDates = reminders
          .where((r) => r.isCompleted && r.completedAt != null)
          .map((r) => r.completedAt!.toLocal())
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (completedDates.isEmpty) return 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(today.year, today.month, today.day - 1);

      // If the latest completed date is neither today nor yesterday, the streak is broken (0)
      if (completedDates.first != today && completedDates.first != yesterday) {
        return 0;
      }

      int streak = 0;
      DateTime checkDate = completedDates.first;

      for (var date in completedDates) {
        if (date == checkDate) {
          streak++;
          checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
        } else {
          break;
        }
      }
      return streak;
    },
    orElse: () => 0,
  );
});

final procrastinationIndexProvider = Provider<ProcrastinationIndexData>((ref) {
  final remindersAsync = ref.watch(remindersStreamProvider);
  return remindersAsync.maybeWhen(
    data: (reminders) {
      if (reminders.isEmpty) {
        return const ProcrastinationIndexData(
          label: "Proactive 👑",
          color: RiriTheme.successGreen,
          avgSnooze: 0.0,
        );
      }
      
      final totalSnoozes = reminders.fold<int>(0, (sum, r) => sum + r.snoozeCount);
      final avg = totalSnoozes / reminders.length;

      String label;
      Color color;

      if (avg <= 0.5) {
        label = "Proactive 👑";
        color = RiriTheme.successGreen;
      } else if (avg <= 1.5) {
        label = "Mild Slacker ☕";
        color = RiriTheme.secondaryAmber;
      } else if (avg <= 3.0) {
        label = "Snooze Master 😴";
        color = RiriTheme.primaryPurple;
      } else {
        label = "Professional Slacker 💀";
        color = RiriTheme.dangerRed;
      }

      return ProcrastinationIndexData(
        label: label,
        color: color,
        avgSnooze: avg,
      );
    },
    orElse: () => const ProcrastinationIndexData(
      label: "Proactive 👑",
      color: RiriTheme.successGreen,
      avgSnooze: 0.0,
    ),
  );
});

final characterStateProvider = Provider<DashboardState>((ref) {
  final remindersAsync = ref.watch(remindersStreamProvider);
  return remindersAsync.maybeWhen(
    data: (reminders) {
      final active = reminders.where((t) => !t.isCompleted).toList();
      if (reminders.isEmpty) return DashboardState.empty;
      if (active.isEmpty) return DashboardState.success;

      final now = DateTime.now();
      final overdueCount = active.where((t) => t.dueDateTime.isBefore(now)).length;

      if (overdueCount > 0) return DashboardState.overdue;

      final workingCount = active.where((t) => t.dueDateTime.difference(now).inHours <= 4).length;
      if (workingCount > 0) return DashboardState.working;

      return DashboardState.ready;
    },
    orElse: () => DashboardState.ready,
  );
});

