import 'package:flutter_test/flutter_test.dart';
import 'package:riri_flutter/core/ai/ai_models.dart';
import 'package:riri_flutter/core/ai/keyword_classifier.dart';

void main() {
  group('TaglishKeywordClassifier Unit Tests', () {
    late TaglishKeywordClassifier classifier;

    setUp(() {
      classifier = TaglishKeywordClassifier();
    });

    test('Should classify school-related tasks correctly', () {
      final input1 = 'Submit thesis draft kay Prof tomorrow morning 📝';
      final input2 = 'Mag-aral para sa upcoming physics exam';

      expect(classifier.classify(input1), ReminderCategory.school);
      expect(classifier.classify(input2), ReminderCategory.school);
    });

    test('Should classify work-related tasks correctly', () {
      final input1 = 'Client presentation deadline at 3pm';
      final input2 = 'Meeting with engineering team regarding sprint progress';

      expect(classifier.classify(input1), ReminderCategory.work);
      expect(classifier.classify(input2), ReminderCategory.work);
    });

    test('Should classify health/gym tasks correctly', () {
      final input1 = 'Doctor check-up and buy medicine at pharmacy';
      final input2 = 'Inom ng gamot after breakfast';

      expect(classifier.classify(input1), ReminderCategory.health);
      expect(classifier.classify(input2), ReminderCategory.health);
    });

    test('Should classify social tasks correctly', () {
      final input1 = 'Tambay with barkada for drinks later 🍻';
      final input2 = 'Birthday party ni bestie sa weekend';

      expect(classifier.classify(input1), ReminderCategory.social);
      expect(classifier.classify(input2), ReminderCategory.social);
    });

    test('Should classify errands correctly', () {
      final input1 = 'Bayad ng electricity bills and internet';
      final input2 = 'Bili ng grocery sa palengke sa Sabado';

      expect(classifier.classify(input1), ReminderCategory.errands);
      expect(classifier.classify(input2), ReminderCategory.errands);
    });

    test('Should classify Bahala Na mode correctly', () {
      final input1 = 'Ewan ko na talaga bahala na kung anong mangyari 🫡';
      final input2 = 'Whatever, di ko alam kung kelan gagawin';

      expect(classifier.classify(input1), ReminderCategory.bahalaNa);
      expect(classifier.classify(input2), ReminderCategory.bahalaNa);
    });

    test('Should default to personal for unclassified inputs', () {
      final input = 'Gusto ko lang matulog and humiga buong hapon';

      expect(classifier.classify(input), ReminderCategory.personal);
    });
  });
}
