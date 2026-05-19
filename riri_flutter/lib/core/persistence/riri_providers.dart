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

/// Tab index manager.
final tabIndexProvider = StateProvider<int>((ref) => 0);

/// Onboarding progress notifier.
final onboardingCompletedProvider = StateProvider<bool>((ref) => false);

/// Username state management.
class UsernameNotifier extends StateNotifier<String> {
  UsernameNotifier() : super('Bestie') {
    loadUsername();
  }

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

final usernameProvider = StateNotifierProvider<UsernameNotifier, String>((ref) {
  return UsernameNotifier();
});
