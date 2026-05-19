import 'package:flutter_test/flutter_test.dart';
import 'package:riri_flutter/core/ai/ai_models.dart';
import 'package:riri_flutter/core/ai/keyword_classifier.dart';

void main() {
  group('TaglishClassifier API & Intent Mapping Tests', () {
    late TaglishKeywordClassifier classifier;

    setUp(() {
      classifier = TaglishKeywordClassifier();
    });

    test('Should parse school-related statements into ParsedReminder with high confidence', () {
      final input = 'Submit thesis draft kay Prof tomorrow morning 📝';
      final parsed = classifier.parse(input);

      expect(parsed.title, input);
      expect(parsed.category, ReminderCategory.school);
      expect(parsed.confidence, greaterThanOrEqualTo(0.85));
      expect(parsed.extractedAt, isA<DateTime>());
    });

    test('Should handle complex Taglish work boundaries', () {
      final input = 'Trabaho at meeting with client about the presentation deadline at 3pm';
      final parsed = classifier.parse(input);

      expect(parsed.category, ReminderCategory.work);
      expect(parsed.confidence, 0.9);
    });

    test('Should capture medical and health indicators', () {
      final input = 'Inom ng gamot at vitamins after workout sa gym';
      final parsed = classifier.parse(input);

      expect(parsed.category, ReminderCategory.health);
      expect(parsed.confidence, 0.85);
    });

    test('Should map informal barkada meetups to social', () {
      final input = 'Inuman at tambay with barkada later at coffee shop 🍻';
      final parsed = classifier.parse(input);

      expect(parsed.category, ReminderCategory.social);
      expect(parsed.confidence, 0.85);
    });

    test('Should identify utility purchases and errand bills', () {
      final input = 'Bayad ng electricity bills and checkout sa shopee';
      final parsed = classifier.parse(input);

      expect(parsed.category, ReminderCategory.errands);
      expect(parsed.confidence, 0.8);
    });

    test('Should parse high-confidence Bahala Na expressions', () {
      final input = 'Ewan ko na talaga, bahala na kung anong mangyari bukas';
      final parsed = classifier.parse(input);

      expect(parsed.category, ReminderCategory.bahalaNa);
      expect(parsed.confidence, 0.95);
    });

    test('Should default to personal category for ambiguous sentences', () {
      final input = 'Mag-relax lang muna buong magdamag';
      final parsed = classifier.parse(input);

      expect(parsed.category, ReminderCategory.personal);
      expect(parsed.confidence, 0.5);
    });
  });
}
