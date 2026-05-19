import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../ai/ai_models.dart';
import '../notifications/personality_copy.dart';

part 'riri_database.g.dart';

/// Bidirectional type converter auto-mapping Dart DateTime instances ↔ SQLite Int epoch milliseconds.
class DateTimeConverter extends TypeConverter<DateTime, int> {
  const DateTimeConverter();

  @override
  DateTime fromSql(int fromDb) {
    return DateTime.fromMillisecondsSinceEpoch(fromDb);
  }

  @override
  int toSql(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}

// Reminders Table
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  
  // Safe enum mappings at database layer
  TextColumn get category => textEnum<ReminderCategory>()();
  TextColumn get personalityMode => textEnum<PersonalityMode>().withDefault(const Constant('bestie'))();
  
  // Custom DateTime converters mapping SQL integers natively
  IntColumn get dueDateTime => integer().map(const DateTimeConverter())();
  IntColumn get createdAt => integer().map(const DateTimeConverter())();
  IntColumn get completedAt => integer().nullable().map(const DateTimeConverter())();
  
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringInterval => text().nullable()();
  TextColumn get recurringRuleJson => text().nullable()();
  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();
  IntColumn get rescheduleCount => integer().withDefault(const Constant(0))();
  TextColumn get rawInput => text().nullable()();
  TextColumn get taglishNormalized => text().nullable()();
  TextColumn get taglishTokensJson => text().nullable()();
  RealColumn get procrastinationScore => real().withDefault(const Constant(0.0))();
}

// Chat Messages Table
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get text => this.text()();
  BoolColumn get isUser => boolean()();
  IntColumn get timestamp => integer().map(const DateTimeConverter())();
  TextColumn get stickerName => text().nullable()();
}

// User Stats Table
class UserStats extends Table {
  IntColumn get weekStartDate => integer().map(const DateTimeConverter())();
  IntColumn get weekEndDate => integer().map(const DateTimeConverter())();
  IntColumn get totalSet => integer()();
  IntColumn get totalCompleted => integer()();
  IntColumn get totalIgnored => integer()();
  IntColumn get totalRescheduled => integer()();
  IntColumn get currentStreak => integer()();
  IntColumn get longestStreak => integer()();
  TextColumn get personalityTitle => text()();
  RealColumn get procrastinationScore => real()();
  IntColumn get lastCompletedDate => integer().withDefault(const Constant(0)).map(const DateTimeConverter())();
  IntColumn get generatedAt => integer().map(const DateTimeConverter())();

  @override
  Set<Column> get primaryKey => {weekStartDate};
}

@DriftDatabase(tables: [Reminders, ChatMessages, UserStats])
class RiriDatabase extends _$RiriDatabase {
  RiriDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Reminders DAOs/Queries
  Future<List<Reminder>> getAllReminders() => select(reminders).get();
  Stream<List<Reminder>> watchAllReminders() => select(reminders).watch();
  Future<int> insertReminder(RemindersCompanion companion) => insert(reminders).insert(companion);
  Future<bool> updateReminder(Reminder reminder) => update(reminders).replace(reminder);
  Future<int> deleteReminder(int id) => (delete(reminders)..where((t) => t.id.equals(id))).go();

  // ChatMessages DAOs/Queries
  Future<List<ChatMessage>> getChatHistory() => select(chatMessages).get();
  Future<int> insertChatMessage(ChatMessagesCompanion companion) => insert(chatMessages).insert(companion);
  Future<void> clearChatHistory() => delete(chatMessages).go();

  // UserStats DAOs/Queries
  Future<UserStat?> getLatestStats() => (select(userStats)..orderBy([(t) => OrderingTerm.desc(t.generatedAt)])).getSingleOrNull();
  Future<int> insertOrUpdateStats(UserStatsCompanion companion) => into(userStats).insertOnConflictUpdate(companion);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'riri_sqlite.db'));
    return NativeDatabase.createInBackground(file);
  });
}
