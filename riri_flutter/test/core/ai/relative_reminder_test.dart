import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:riri_flutter/core/ai/chat_response_engine.dart';
import 'package:riri_flutter/core/notifications/personality_copy.dart';

void main() {
  const examples = [
    (
      input: 'Remind me to buy coffee in 2 hours',
      title: 'buy coffee',
      delay: Duration(hours: 2),
    ),
    (
      input: 'Paalala mo thesis draft PAGKALIPAS NG 30 MINUTO!',
      title: 'thesis draft',
      delay: Duration(minutes: 30),
    ),
    (
      input: 'Remind me to print tomorrow’s notes in 1 minute.',
      title: 'print tomorrow’s notes',
      delay: Duration(minutes: 1),
    ),
    (
      input: 'Paalala mo magbayad pagkalipas ng 1 oras',
      title: 'magbayad',
      delay: Duration(hours: 1),
    ),
    (
      input: 'Remind me to try the 5 minutes challenge',
      title: 'try the 5 minutes challenge',
      delay: Duration(hours: 4),
    ),
    (
      input: 'Remind me to buy coffee in 0 hours',
      title: 'buy coffee in 0 hours',
      delay: Duration(hours: 4),
    ),
  ];

  for (final example in examples) {
    test('proposes the expected task card for "${example.input}"', () {
      final engine = ChatResponseEngine();
      const prefix = '[TASK_CARD]';
      final earliest = DateTime.now().add(example.delay);
      final response = engine.generateResponse(
        userInput: example.input,
        personalityMode: PersonalityMode.bestie,
      );
      final latest = DateTime.now().add(example.delay);

      expect(response.text, startsWith(prefix));
      final card =
          jsonDecode(response.text.substring(prefix.length))
              as Map<String, dynamic>;
      final dueDate = DateTime.parse(card['dueDate'] as String);
      expect(
        dueDate.isBefore(earliest) || dueDate.isAfter(latest),
        isFalse,
        reason:
            'Expected a due time between $earliest and $latest, got $dueDate',
      );
      expect(card['title'], example.title);
      expect(card['state'], 'pending');
    });
  }
}
