import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
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

      final validReplies = [
        'Hoy! Handang-handa na ako rito. Kumusta ang araw natin? ✨',
        'Hello! Kape muna tapos checklist completed na ba? Ready to achieve our goals today? ☕',
        'Yow! Ano’ng ganap natin today? May ipapaalala ka ba? 📣',
      ];
      expect(validReplies, contains(response.text));
      expect(response.stickerName, 'Welcoming');
    });

    test('Should respond with maximum roast in Malupit mode', () {
      final input = 'hi riri';
      final response = engine.generateResponse(
        userInput: input,
        personalityMode: PersonalityMode.malupit,
      );

      final validReplies = [
        'Bakit ka bumabati? May natapos ka na bang task? Focus.',
        'Walang hi-hi dito. Trabaho muna. Sayang ang oras.',
        'Kumusta? Heto, naiistress sa kabagalan mo. Galaw-galaw!',
      ];
      expect(validReplies, contains(response.text));
      expect(response.stickerName, 'Angry');
    });

    test('Should extract name from conversation and generate customized responses', () {
      // Test the extraction patterns
      expect(engine.tryExtractName('ako si Joshua'), 'Joshua');
      expect(engine.tryExtractName('ako nga pala si Maria'), 'Maria');
      expect(engine.tryExtractName('tawagin mo akong Joshua'), 'Joshua');
      expect(engine.tryExtractName('my name is Clara'), 'Clara');
      expect(engine.tryExtractName("i'm Joshua"), 'Joshua');

      // Test response generation with learned name
      final responseBestie = engine.generateResponse(
        userInput: 'ako si Joshua',
        personalityMode: PersonalityMode.bestie,
        newlyLearnedName: 'Joshua',
      );
      expect(responseBestie.text, contains('Joshua'));
      expect(responseBestie.text, contains('tatandaan ko'));
      expect(responseBestie.stickerName, 'Welcoming');

      final responseMalupit = engine.generateResponse(
        userInput: 'ako si Joshua',
        personalityMode: PersonalityMode.malupit,
        newlyLearnedName: 'Joshua',
      );
      expect(responseMalupit.text, contains('Joshua'));
      expect(responseMalupit.text, contains('huwag kang tamad'));
      expect(responseMalupit.stickerName, 'Angry');
    });

    test('Should handle interactive Rock-Paper-Scissors game', () {
      // 1. Initial laro game request
      final gameResponse = engine.generateResponse(
        userInput: 'maglaro tayo ng game',
        personalityMode: PersonalityMode.bestie,
      );
      expect(gameResponse.text, contains('Bato-Bato-Pick'));

      // 2. Play with a choice
      final playResponse = engine.generateResponse(
        userInput: 'pili ko ay Bato',
        personalityMode: PersonalityMode.bestie,
      );
      expect(playResponse.text, anyOf([
        contains('Draw'),
        contains('panalo'),
        contains('Talo'),
      ]));
    });

    test('Should parse alarm triggers and time patterns correctly', () {
      // 1. Set alarm command
      final alarmResponse = engine.generateResponse(
        userInput: 'set alarm at 8:30 AM',
        personalityMode: PersonalityMode.bestie,
      );
      expect(alarmResponse.text, contains('8:30 AM'));
      expect(alarmResponse.text, contains('alarm'));

      // 2. Wake up request
      final wakeUpResponse = engine.generateResponse(
        userInput: 'gisingin mo ako ng 6:00',
        personalityMode: PersonalityMode.tita,
      );
      expect(wakeUpResponse.text, contains('6:00'));
      expect(wakeUpResponse.text, contains('anak'));
    });

    test('Should trigger custom lifestyle chika for jokes, food, and sleep', () {
      // 1. Joke/Chika
      final jokeResponse = engine.generateResponse(
        userInput: 'kwento naman ng chika o joke',
        personalityMode: PersonalityMode.bestie,
      );
      expect(jokeResponse.text, anyOf([
        contains('budots'),
        contains('kalendaryo'),
        contains('multo'),
      ]));

      // 2. Hungry
      final foodResponse = engine.generateResponse(
        userInput: 'gutom na ako kain na tayo',
        personalityMode: PersonalityMode.tita,
      );
      expect(foodResponse.text, anyOf([
        contains('sinigang'),
        contains('tanghalian'),
      ]));

      // 3. Sleep
      final sleepResponse = engine.generateResponse(
        userInput: 'antok na ako tulog na ako',
        personalityMode: PersonalityMode.chill,
      );
      expect(sleepResponse.text, anyOf([
        contains('Higa'),
        contains('Goodnight'),
      ]));
    });
  });

  group('RiriRepository SQLite Tests', () {
    late RiriDatabase database;
    late RiriRepository repository;

    setUp(() async {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData({});
      // Initialize a clean, high-performance in-memory SQLite Drift database for testing
      database = RiriDatabase(NativeDatabase.memory());
      repository = RiriRepository(database: database);
      // Allow async seeding to complete
      await Future.delayed(const Duration(milliseconds: 50));
    });

    tearDown(() async {
      repository.dispose();
      await database.close();
    });

    test('Should add and retrieve a reminder cleanly with synchronous DB flow', () async {
      final now = DateTime.now();
      await repository.addReminder(
        title: 'Review for Programming Exam',
        category: ReminderCategory.school,
        dueDateTime: now.add(const Duration(hours: 2)),
      );
      // Allow the reactive stream event to update cachedReminders
      await Future.delayed(const Duration(milliseconds: 50));

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
      // Allow reactive stream to update cachedReminders
      await Future.delayed(const Duration(milliseconds: 50));

      final matchingBefore = repository.currentReminders.firstWhere((r) => r.title == 'Bumili ng gatas 🥛');
      final id = matchingBefore.id;

      await repository.toggleReminderCompletion(id);
      // Allow reactive stream to update
      await Future.delayed(const Duration(milliseconds: 50));
      
      final listAfterToggle = repository.currentReminders;
      expect(listAfterToggle.firstWhere((r) => r.id == id).isCompleted, isTrue);

      await repository.deleteReminder(id);
      // Allow reactive stream to update
      await Future.delayed(const Duration(milliseconds: 50));
      
      final listAfterDelete = repository.currentReminders;
      expect(listAfterDelete.any((r) => r.id == id), isFalse);
    });

    test('Should add and clear chat messages with unified timestamps', () async {
      await repository.addChatMessage(
        text: 'Hello Riri!',
        isUser: true,
        stickerName: 'Wink',
      );
      // Allow async pre-load or updates to complete
      await Future.delayed(const Duration(milliseconds: 50));

      final messages = repository.chatHistory;
      expect(messages.length, 1);
      expect(messages.first.text, 'Hello Riri!');
      expect(messages.first.stickerName, 'Wink');
      expect(messages.first.isUser, isTrue);

      await repository.clearChatHistory();
      // Allow async clear to complete
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(repository.chatHistory.isEmpty, isTrue);
    });
  });
}
