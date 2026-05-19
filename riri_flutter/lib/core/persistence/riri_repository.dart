import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../ai/ai_models.dart';
import '../notifications/personality_copy.dart';

class RiriReminder {
  final int id;
  final String title;
  final String? description;
  final ReminderCategory category;
  final DateTime dueDateTime;
  final bool isCompleted;
  final int snoozeCount;
  final int rescheduleCount;
  final DateTime createdAt;
  final DateTime? completedAt;

  RiriReminder({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.dueDateTime,
    this.isCompleted = false,
    this.snoozeCount = 0,
    this.rescheduleCount = 0,
    required this.createdAt,
    this.completedAt,
  });

  RiriReminder copyWith({
    int? id,
    String? title,
    String? description,
    ReminderCategory? category,
    DateTime? dueDateTime,
    bool? isCompleted,
    int? snoozeCount,
    int? rescheduleCount,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return RiriReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      rescheduleCount: rescheduleCount ?? this.rescheduleCount,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class RiriChatMessage {
  final int id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? stickerName;

  RiriChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.stickerName,
  });
}

class RiriRepository {
  final List<RiriReminder> _inMemoryReminders = [];
  final List<RiriChatMessage> _inMemoryChatHistory = [];
  final StreamController<List<RiriReminder>> _remindersController =
      StreamController<List<RiriReminder>>.broadcast();

  RiriRepository() {
    final now = DateTime.now();
    _inMemoryReminders.addAll([
      RiriReminder(
        id: 1,
        title: 'Submit thesis draft kay Prof 📝',
        description: 'Kailangan na talaga to kundi lagot na.',
        category: ReminderCategory.school,
        dueDateTime: now.add(const Duration(hours: 3)),
        createdAt: now,
      ),
      RiriReminder(
        id: 2,
        title: 'Bili ng kape at grocery sa palengke 🛒',
        description: 'Kape is life bestie, baka antukin sa review.',
        category: ReminderCategory.errands,
        dueDateTime: now.add(const Duration(days: 1)),
        createdAt: now,
      ),
      RiriReminder(
        id: 3,
        title: 'Uminom ng vitamins / mag gym 💪',
        description: 'Huwag puro puyat bes, alagaan din ang katawan.',
        category: ReminderCategory.health,
        dueDateTime: now.add(const Duration(days: 2)),
        createdAt: now,
      ),
    ]);
    _remindersController.add(List.unmodifiable(_inMemoryReminders));
  }

  Stream<List<RiriReminder>> get remindersStream => _remindersController.stream;

  List<RiriReminder> get currentReminders => List.unmodifiable(_inMemoryReminders);

  Future<void> addReminder({
    required String title,
    String? description,
    required ReminderCategory category,
    required DateTime dueDateTime,
  }) async {
    final nextId = _inMemoryReminders.isEmpty
        ? 1
        : _inMemoryReminders.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;

    final newReminder = RiriReminder(
      id: nextId,
      title: title,
      description: description,
      category: category,
      dueDateTime: dueDateTime,
      createdAt: DateTime.now(),
    );

    _inMemoryReminders.add(newReminder);
    _remindersController.add(List.unmodifiable(_inMemoryReminders));
  }

  Future<void> toggleReminderCompletion(int id) async {
    final index = _inMemoryReminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final old = _inMemoryReminders[index];
      _inMemoryReminders[index] = old.copyWith(
        isCompleted: !old.isCompleted,
        completedAt: !old.isCompleted ? DateTime.now() : null,
      );
      _remindersController.add(List.unmodifiable(_inMemoryReminders));
    }
  }

  Future<void> deleteReminder(int id) async {
    _inMemoryReminders.removeWhere((r) => r.id == id);
    _remindersController.add(List.unmodifiable(_inMemoryReminders));
  }

  List<RiriChatMessage> get chatHistory => List.unmodifiable(_inMemoryChatHistory);

  Future<void> addChatMessage({
    required String text,
    required bool isUser,
    String? stickerName,
  }) async {
    final nextId = _inMemoryChatHistory.isEmpty
        ? 1
        : _inMemoryChatHistory.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;

    final message = RiriChatMessage(
      id: nextId,
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
      stickerName: stickerName,
    );

    _inMemoryChatHistory.add(message);
  }

  Future<void> clearChatHistory() async {
    _inMemoryChatHistory.clear();
  }

  static const String _prefPersonalityKey = 'riri_personality_mode';
  static const String _prefNotificationsKey = 'riri_notifications_enabled';

  Future<PersonalityMode> getPersonalityMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_prefPersonalityKey);
    return PersonalityMode.fromDbValue(modeStr ?? 'bestie');
  }

  Future<void> setPersonalityMode(PersonalityMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefPersonalityKey, mode.toDbValue());
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefNotificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefNotificationsKey, enabled);
  }
}
