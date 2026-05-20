import 'dart:async';
import 'dart:convert';
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

class RiriChatThread {
  final String id;
  final String title;
  final DateTime createdAt;

  RiriChatThread({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RiriChatThread.fromJson(Map<String, dynamic> json) => RiriChatThread(
        id: json['id'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class RiriRepository {
  final RiriDatabase _db;
  final List<RiriChatMessage> _cachedChatHistory = [];
  
  final StreamController<List<RiriChatMessage>> _chatHistoryController =
      StreamController<List<RiriChatMessage>>.broadcast();

  StreamSubscription<List<Reminder>>? _dbSubscription;
  List<RiriReminder> _cachedReminders = [];

  // Thread Management Fields
  final List<RiriChatThread> _threads = [];
  String _activeThreadId = 'default';

  final StreamController<List<RiriChatThread>> _threadsController =
      StreamController<List<RiriChatThread>>.broadcast();

  RiriRepository({required RiriDatabase database}) : _db = database {
    // 1. Subscribe to SQLite reactive stream to populate cache and stream updates
    _dbSubscription = _db.watchAllReminders().listen((dbList) {
      _cachedReminders = dbList.map((r) => _mapReminder(r)).toList();
    });

    // 2. Perform DB Seeding if empty
    _seedDbIfEmpty();

    // 3. Pre-load threads and active chat history asynchronously
    _initThreadsAsync();
  }

  void dispose() {
    _dbSubscription?.cancel();
    _threadsController.close();
    _chatHistoryController.close();
  }

  Future<void> _seedDbIfEmpty() async {
    final existing = await _db.getAllReminders();
    if (existing.isEmpty) {
      final now = DateTime.now();
      await _db.insertReminder(RemindersCompanion.insert(
        title: 'Simulan ang first productivity task mo! 📝',
        description: const Value('Welcome to Riri! Kaya natin to! Tap the circle when done.'),
        category: ReminderCategory.personal,
        dueDateTime: now.add(const Duration(hours: 3)),
        createdAt: now,
      ));
      await _db.insertReminder(RemindersCompanion.insert(
        title: 'Mag-hydrate at uminom ng tubig 💧',
        description: const Value('Stay healthy para tuloy-tuloy ang productivity vibe!'),
        category: ReminderCategory.health,
        dueDateTime: now.add(const Duration(days: 1)),
        createdAt: now,
      ));
      await _db.insertReminder(RemindersCompanion.insert(
        title: 'Magplano para sa susunod na mga araw 📅',
        description: const Value('Ilista na ang iyong upcoming tasks o errands kasama si Riri.'),
        category: ReminderCategory.personal,
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
      text: m.messageText,
      isUser: m.isUser,
      timestamp: m.timestamp,
      stickerName: m.stickerName,
    );
  }

  Stream<List<RiriReminder>> get remindersStream =>
      _db.watchAllReminders().map((list) => list.map(_mapReminder).toList());

  Stream<List<RiriChatMessage>> get chatHistoryStream => _chatHistoryController.stream;

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
    final item = await _db.getReminderById(id);
    if (item == null) return;
    final updated = item.copyWith(
      isCompleted: !item.isCompleted,
      completedAt: Value(!item.isCompleted ? DateTime.now() : null),
    );
    await _db.updateReminder(updated);
  }

  Future<void> deleteReminder(int id) async {
    await _db.deleteReminder(id);
  }

  // --- Chat Threads Management & Persistent Migration ---

  static const String _prefThreadsKey = 'riri_chat_threads';
  static const String _prefActiveThreadIdKey = 'riri_active_thread_id';

  final _prefs = SharedPreferencesAsync();

  List<RiriChatThread> get threads => List.unmodifiable(_threads);
  String get activeThreadId => _activeThreadId;
  Stream<List<RiriChatThread>> get threadsStream => _threadsController.stream;

  Future<void> _initThreadsAsync() async {
    try {
      final threadsJson = await _prefs.getString(_prefThreadsKey);
      final activeId = await _prefs.getString(_prefActiveThreadIdKey);

      if (threadsJson != null && threadsJson.isNotEmpty) {
        final decoded = json.decode(threadsJson) as List<dynamic>;
        _threads.clear();
        _threads.addAll(decoded.map((item) => RiriChatThread.fromJson(item as Map<String, dynamic>)));
        _activeThreadId = activeId ?? _threads.first.id;
      } else {
        // Initial setup - default first thread
        final defaultThread = RiriChatThread(
          id: 'default',
          title: 'New Thread',
          createdAt: DateTime.now(),
        );
        _threads.add(defaultThread);
        _activeThreadId = 'default';
        await _saveThreadsToPrefs();
      }

      // Seed any existing SQLite messages (schema v < 3 migration helper)
      await _db.seedNullThreadIds(_activeThreadId);

      // Load active thread history
      await _loadActiveThreadHistory();
      _threadsController.add(List.unmodifiable(_threads));
    } catch (e) {
      if (_threads.isEmpty) {
        _threads.add(RiriChatThread(id: 'default', title: 'New Thread', createdAt: DateTime.now()));
        _activeThreadId = 'default';
      }
      await _loadActiveThreadHistory();
      _threadsController.add(List.unmodifiable(_threads));
    }
  }

  Future<void> _saveThreadsToPrefs() async {
    final encoded = json.encode(_threads.map((t) => t.toJson()).toList());
    await _prefs.setString(_prefThreadsKey, encoded);
    await _prefs.setString(_prefActiveThreadIdKey, _activeThreadId);
  }

  Future<void> _loadActiveThreadHistory() async {
    final dbMsgs = await _db.getChatHistoryByThread(_activeThreadId);
    _cachedChatHistory.clear();
    _cachedChatHistory.addAll(dbMsgs.map((m) => _mapChatMessage(m)));
    _chatHistoryController.add(List.unmodifiable(_cachedChatHistory));
  }

  Future<void> switchActiveThread(String threadId) async {
    _activeThreadId = threadId;
    await _prefs.setString(_prefActiveThreadIdKey, _activeThreadId);
    await _loadActiveThreadHistory();
    _threadsController.add(List.unmodifiable(_threads));
  }

  Future<void> createNewThread({required String id, required String title}) async {
    final newThread = RiriChatThread(
      id: id,
      title: title,
      createdAt: DateTime.now(),
    );
    _threads.insert(0, newThread); // Insert at beginning
    _activeThreadId = id;
    await _saveThreadsToPrefs();
    await _loadActiveThreadHistory();
    _threadsController.add(List.unmodifiable(_threads));
  }

  Future<void> deleteThread(String threadId) async {
    _threads.removeWhere((t) => t.id == threadId);
    await _db.deleteChatHistoryByThread(threadId);

    if (_activeThreadId == threadId) {
      if (_threads.isNotEmpty) {
        _activeThreadId = _threads.first.id;
      } else {
        final defaultThread = RiriChatThread(
          id: 'default',
          title: 'New Thread',
          createdAt: DateTime.now(),
        );
        _threads.add(defaultThread);
        _activeThreadId = 'default';
      }
    }
    await _saveThreadsToPrefs();
    await _loadActiveThreadHistory();
    _threadsController.add(List.unmodifiable(_threads));
  }

  Future<void> updateThreadTitle(String threadId, String title) async {
    final idx = _threads.indexWhere((t) => t.id == threadId);
    if (idx != -1) {
      final old = _threads[idx];
      _threads[idx] = RiriChatThread(
        id: old.id,
        title: title,
        createdAt: old.createdAt,
      );
      await _saveThreadsToPrefs();
      _threadsController.add(List.unmodifiable(_threads));
    }
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

    final isNewTitleNeeded = isUser &&
        _cachedChatHistory.isEmpty &&
        _threads.any((t) => t.id == _activeThreadId && t.title == 'New Thread');

    _cachedChatHistory.add(message);
    await _db.insertChatMessage(ChatMessagesCompanion.insert(
      messageText: text,
      isUser: isUser,
      timestamp: now,
      stickerName: Value(stickerName),
      threadId: Value(_activeThreadId),
    ));

    if (isNewTitleNeeded) {
      final newTitle = text.length > 25 ? '${text.substring(0, 25)}...' : text;
      await updateThreadTitle(_activeThreadId, newTitle);
    }
    _chatHistoryController.add(List.unmodifiable(_cachedChatHistory));
  }

  Future<void> updateChatMessageText(int id, String newText) async {
    final index = _cachedChatHistory.indexWhere((m) => m.id == id);
    if (index != -1) {
      final old = _cachedChatHistory[index];
      _cachedChatHistory[index] = RiriChatMessage(
        id: old.id,
        text: newText,
        isUser: old.isUser,
        timestamp: old.timestamp,
        stickerName: old.stickerName,
      );
      _chatHistoryController.add(List.unmodifiable(_cachedChatHistory));
    }
    await _db.updateChatMessageText(id, newText);
  }

  Future<void> clearChatHistory() async {
    _cachedChatHistory.clear();
    _chatHistoryController.add(List.unmodifiable(_cachedChatHistory));
    await _db.deleteChatHistoryByThread(_activeThreadId);
  }

  static const String _prefPersonalityKey = 'riri_personality_mode';
  static const String _prefNotificationsKey = 'riri_notifications_enabled';

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

  /// Exports all chat threads, messages, and reminders into a single backup JSON string.
  Future<String> exportDataAsJson() async {
    final reminders = await _db.getAllReminders();
    final chatMessages = await _db.getChatHistory();
    
    final remindersList = reminders.map((r) => {
      'title': r.title,
      'description': r.description,
      'category': r.category.name,
      'dueDateTime': r.dueDateTime.toIso8601String(),
      'isCompleted': r.isCompleted,
      'snoozeCount': r.snoozeCount,
      'rescheduleCount': r.rescheduleCount,
      'createdAt': r.createdAt.toIso8601String(),
      'completedAt': r.completedAt?.toIso8601String(),
    }).toList();

    final chatMessagesList = chatMessages.map((m) => {
      'messageText': m.messageText,
      'isUser': m.isUser,
      'timestamp': m.timestamp.toIso8601String(),
      'stickerName': m.stickerName,
      'threadId': m.threadId,
    }).toList();

    final threadsList = _threads.map((t) => t.toJson()).toList();

    final backupData = {
      'version': 1,
      'reminders': remindersList,
      'chatMessages': chatMessagesList,
      'threads': threadsList,
      'activeThreadId': _activeThreadId,
    };

    return jsonEncode(backupData);
  }

  /// Restores all chat threads, messages, and reminders from a backup JSON string.
  Future<bool> importDataFromJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      if (decoded['version'] != 1) return false;

      // 1. Purge database
      await _db.purgeDatabase();

      // 2. Import Reminders
      final remindersList = decoded['reminders'] as List<dynamic>;
      for (final r in remindersList) {
        final map = r as Map<String, dynamic>;
        await _db.insertReminder(RemindersCompanion.insert(
          title: map['title'] as String,
          description: map['description'] != null ? Value(map['description'] as String) : const Value.absent(),
          category: ReminderCategory.fromDbValue(map['category'] as String),
          dueDateTime: DateTime.parse(map['dueDateTime'] as String),
          isCompleted: Value(map['isCompleted'] as bool),
          snoozeCount: Value(map['snoozeCount'] as int),
          rescheduleCount: Value(map['rescheduleCount'] as int),
          createdAt: DateTime.parse(map['createdAt'] as String),
          completedAt: map['completedAt'] != null ? Value(DateTime.parse(map['completedAt'] as String)) : const Value.absent(),
        ));
      }

      // 3. Import Chat Messages
      final chatMessagesList = decoded['chatMessages'] as List<dynamic>;
      for (final m in chatMessagesList) {
        final map = m as Map<String, dynamic>;
        await _db.insertChatMessage(ChatMessagesCompanion.insert(
          messageText: map['messageText'] as String,
          isUser: map['isUser'] as bool,
          timestamp: DateTime.parse(map['timestamp'] as String),
          stickerName: map['stickerName'] != null ? Value(map['stickerName'] as String) : const Value.absent(),
          threadId: map['threadId'] != null ? Value(map['threadId'] as String) : const Value.absent(),
        ));
      }

      // 4. Import Threads metadata
      final threadsList = decoded['threads'] as List<dynamic>;
      _threads.clear();
      for (final t in threadsList) {
        _threads.add(RiriChatThread.fromJson(t as Map<String, dynamic>));
      }

      _activeThreadId = decoded['activeThreadId'] as String? ?? 'default';
      
      // Save threads metadata back to SharedPreferences
      await _saveThreadsToPrefs();
      
      // Trigger local memory cache refresh
      await switchActiveThread(_activeThreadId);
      
      // Broadcast threads update
      _threadsController.add(List.unmodifiable(_threads));

      return true;
    } catch (_) {
      return false;
    }
  }
}
