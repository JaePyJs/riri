import 'dart:async';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ai/ai_models.dart';
import '../notifications/personality_copy.dart';
import 'riri_database.dart';

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
  final RiriDatabase _db;
  final List<RiriChatMessage> _cachedChatHistory = [];
  
  final StreamController<List<RiriReminder>> _remindersController =
      StreamController<List<RiriReminder>>.broadcast();
  StreamSubscription<List<Reminder>>? _dbSubscription;
  List<RiriReminder> _cachedReminders = [];

  RiriRepository({required RiriDatabase database}) : _db = database {
    // 1. Subscribe to SQLite reactive stream to populate cache and stream updates
    _dbSubscription = _db.watchAllReminders().listen((dbList) {
      _cachedReminders = dbList.map((r) => _mapReminder(r)).toList();
      _remindersController.add(List.unmodifiable(_cachedReminders));
    });

    // 2. Perform DB Seeding if empty
    _seedDbIfEmpty();

    // 3. Pre-load chat history asynchronously into our active cache
    _db.getChatHistory().then((dbMsgs) {
      _cachedChatHistory.addAll(dbMsgs.map((m) => _mapChatMessage(m)));
    });
  }

  void dispose() {
    _dbSubscription?.cancel();
    _remindersController.close();
  }

  Future<void> _seedDbIfEmpty() async {
    final existing = await _db.getAllReminders();
    if (existing.isEmpty) {
      final now = DateTime.now();
      await _db.insertReminder(RemindersCompanion.insert(
        title: 'Submit thesis draft kay Prof 📝',
        description: const Value('Kailangan na talaga to kundi lagot na.'),
        category: ReminderCategory.school,
        dueDateTime: now.add(const Duration(hours: 3)),
        createdAt: now,
      ));
      await _db.insertReminder(RemindersCompanion.insert(
        title: 'Bili ng kape at grocery sa palengke 🛒',
        description: const Value('Kape is life bestie, baka antukin sa review.'),
        category: ReminderCategory.errands,
        dueDateTime: now.add(const Duration(days: 1)),
        createdAt: now,
      ));
      await _db.insertReminder(RemindersCompanion.insert(
        title: 'Uminom ng vitamins / mag gym 💪',
        description: const Value('Huwag puro puyat bes, alagaan din ang katawan.'),
        category: ReminderCategory.health,
        dueDateTime: now.add(const Duration(days: 2)),
        createdAt: now,
      ));
    }
  }

  RiriReminder _mapReminder(Reminder r) {
    return RiriReminder(
      id: r.id,
      title: r.title,
      description: r.description,
      category: r.category,
      dueDateTime: r.dueDateTime,
      isCompleted: r.isCompleted,
      snoozeCount: r.snoozeCount,
      rescheduleCount: r.rescheduleCount,
      createdAt: r.createdAt,
      completedAt: r.completedAt,
    );
  }

  RiriChatMessage _mapChatMessage(ChatMessage m) {
    return RiriChatMessage(
      id: m.id,
      text: m.text,
      isUser: m.isUser,
      timestamp: m.timestamp,
      stickerName: m.stickerName,
    );
  }

  Stream<List<RiriReminder>> get remindersStream => _remindersController.stream;

  List<RiriReminder> get currentReminders => List.unmodifiable(_cachedReminders);

  Future<void> addReminder({
    required String title,
    String? description,
    required ReminderCategory category,
    required DateTime dueDateTime,
  }) async {
    await _db.insertReminder(RemindersCompanion.insert(
      title: title,
      description: Value(description),
      category: category,
      dueDateTime: dueDateTime,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> toggleReminderCompletion(int id) async {
    final existing = await _db.getAllReminders();
    final item = existing.firstWhere((r) => r.id == id);
    final updated = item.copyWith(
      isCompleted: !item.isCompleted,
      completedAt: Value(!item.isCompleted ? DateTime.now() : null),
    );
    await _db.updateReminder(updated);
  }

  Future<void> deleteReminder(int id) async {
    await _db.deleteReminder(id);
  }

  List<RiriChatMessage> get chatHistory => List.unmodifiable(_cachedChatHistory);

  Future<void> addChatMessage({
    required String text,
    required bool isUser,
    String? stickerName,
  }) async {
    final now = DateTime.now();
    final nextId = _cachedChatHistory.isEmpty
        ? 1
        : _cachedChatHistory.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;

    final message = RiriChatMessage(
      id: nextId,
      text: text,
      isUser: isUser,
      timestamp: now,
      stickerName: stickerName,
    );

    _cachedChatHistory.add(message);
    await _db.insertChatMessage(ChatMessagesCompanion.insert(
      text: text,
      isUser: isUser,
      timestamp: now,
      stickerName: Value(stickerName),
    ));
  }

  Future<void> clearChatHistory() async {
    _cachedChatHistory.clear();
    await _db.clearChatHistory();
  }

  static const String _prefPersonalityKey = 'riri_personality_mode';
  static const String _prefNotificationsKey = 'riri_notifications_enabled';

  final _prefs = SharedPreferencesAsync();

  Future<PersonalityMode> getPersonalityMode() async {
    final modeStr = await _prefs.getString(_prefPersonalityKey);
    return PersonalityMode.fromDbValue(modeStr ?? 'bestie');
  }

  Future<void> setPersonalityMode(PersonalityMode mode) async {
    await _prefs.setString(_prefPersonalityKey, mode.toDbValue());
  }

  Future<bool> getNotificationsEnabled() async {
    final notifs = await _prefs.getBool(_prefNotificationsKey);
    return notifs ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_prefNotificationsKey, enabled);
  }
}
