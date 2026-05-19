import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:riri_flutter/core/ai/ai_models.dart';
import 'package:riri_flutter/core/ai/chat_response_engine.dart';
import 'package:riri_flutter/core/persistence/riri_database.dart';
import 'package:riri_flutter/core/persistence/riri_repository.dart';
import 'package:riri_flutter/core/notifications/personality_copy.dart';
import 'package:riri_flutter/core/notifications/personas.dart';

void main() {
  group('PersonaTemplate Tests', () {
    test('Should interpolate task variables correctly inside renderTitle', () {
      const template = PersonaTemplate(
        title: 'Reminder for {task}',
        body: 'Do not forget to complete {task} in {days} days!',
      );

      final renderedTitle = template.renderTitle({'task': 'thesis'});
      final renderedBody = template.renderBody({'task': 'thesis', 'days': '5'});

      expect(renderedTitle, 'Reminder for thesis');
      expect(renderedBody, 'Do not forget to complete thesis in 5 days!');
    });
  });

  group('ChatResponseEngine Tests', () {
    late ChatResponseEngine engine;

    setUp(() {
      engine = ChatResponseEngine();
    });

    test('Should parse tomorrow morning time trigger correctly', () {
      final input = 'paalala mo thesis bukas ng umaga';
      final response = engine.generateResponse(
        userInput: input,
        personalityMode: PersonalityMode.bestie,
      );

      expect(response.extractedTitle, 'thesis');
      expect(response.extractedCategory, ReminderCategory.school);
      expect(response.text, "Uy, reminder mo: thesis. Let's get it done!");
      expect(response.extractedDueDate, isNotNull);
      
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(response.extractedDueDate!.year, tomorrow.year);
      expect(response.extractedDueDate!.month, tomorrow.month);
      expect(response.extractedDueDate!.day, tomorrow.day);
      expect(response.extractedDueDate!.hour, 9);
    });

    test('Should parse next week time trigger correctly', () {
      final input = 'gawin natin to next week';
      final response = engine.generateResponse(
        userInput: input,
        personalityMode: PersonalityMode.chill,
      );

      expect(response.extractedTitle, 'to');
      expect(response.extractedDueDate, isNotNull);
      final difference = response.extractedDueDate!.difference(DateTime.now()).inDays;
      expect(difference, greaterThanOrEqualTo(6));
    });

    test('Should respond with correct Bestie greeting and sticker', () {
      final input = 'hello hoy riri';
      final response = engine.generateResponse(
        userInput: input,
        personalityMode: PersonalityMode.bestie,
      );

      expect(response.text, contains('Hoy din bestie'));
      expect(response.stickerName, 'Welcoming');
    });

    test('Should respond with maximum roast in Malupit mode', () {
      final input = 'hi riri';
      final response = engine.generateResponse(
        userInput: input,
        personalityMode: PersonalityMode.malupit,
      );

      expect(response.text, contains('Bakit ka bumabati'));
      expect(response.stickerName, 'Angry');
    });
  });

  group('RiriRepository SQLite Tests', () {
    late RiriDatabase database;
    late RiriRepository repository;

    setUp(() {
      // Initialize a clean, high-performance in-memory SQLite Drift database for testing
      database = RiriDatabase(NativeDatabase.memory());
      repository = RiriRepository(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('Should add and retrieve a reminder cleanly with synchronous DB flow', () async {
      final now = DateTime.now();
      await repository.addReminder(
        title: 'Review for Programming Exam',
        category: ReminderCategory.school,
        dueDateTime: now.add(const Duration(hours: 2)),
      );

      final reminders = repository.currentReminders;
      // Note: Seed tasks might exist, verify added task is present in list
      final matching = reminders.where((r) => r.title == 'Review for Programming Exam').toList();
      
      expect(matching.length, 1);
      expect(matching.first.category, ReminderCategory.school);
      expect(matching.first.isCompleted, isFalse);
    });

    test('Should toggle and delete a reminder from in-memory DB cleanly', () async {
      final now = DateTime.now();
      await repository.addReminder(
        title: 'Bumili ng gatas 🥛',
        category: ReminderCategory.errands,
        dueDateTime: now.add(const Duration(hours: 1)),
      );

      final matchingBefore = repository.currentReminders.firstWhere((r) => r.title == 'Bumili ng gatas 🥛');
      final id = matchingBefore.id;

      await repository.toggleReminderCompletion(id);
      final listAfterToggle = repository.currentReminders;
      expect(listAfterToggle.firstWhere((r) => r.id == id).isCompleted, isTrue);

      await repository.deleteReminder(id);
      final listAfterDelete = repository.currentReminders;
      expect(listAfterDelete.any((r) => r.id == id), isFalse);
    });

    test('Should add and clear chat messages with unified timestamps', () async {
      await repository.addChatMessage(
        text: 'Hello Riri!',
        isUser: true,
        stickerName: 'Wink',
      );

      final messages = repository.chatHistory;
      expect(messages.length, 1);
      expect(messages.first.text, 'Hello Riri!');
      expect(messages.first.stickerName, 'Wink');
      expect(messages.first.isUser, isTrue);

      await repository.clearChatHistory();
      expect(repository.chatHistory.isEmpty, isTrue);
    });
  });
}
