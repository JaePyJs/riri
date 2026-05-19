import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    state = index;
  }
}

final tabIndexProvider = NotifierProvider<TabIndexNotifier, int>(() => TabIndexNotifier());

/// Modern Riverpod 2.x Notifier for Onboarding Completed state.
class OnboardingCompletedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

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
  String build() => 'Bestie';

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
