import 'ai_models.dart';

/// Structured output returned by Riri's Taglish Natural Language Classifier.
class ParsedReminder {
  /// The raw parsed text extracted from the user's statement.
  final String title;

  /// The parsed category mapped from colloquial keywords.
  final ReminderCategory category;

  /// The confidence score of this heuristic classification (range: 0.0 to 1.0).
  final double confidence;

  /// Timestamp indicating when this extraction was processed.
  final DateTime extractedAt;

  ParsedReminder({
    required this.title,
    required this.category,
    required this.confidence,
    required this.extractedAt,
  });
}

/// Heuristic intent parser designed to process colloquial Taglish (Tagalog-English mix) input.
class TaglishKeywordClassifier {
  
  /// Parses raw user statements and converts them to a structured [ParsedReminder] package.
  ParsedReminder parse(String input) {
    final lowerInput = input.toLowerCase();
    
    ReminderCategory category = ReminderCategory.personal;
    double confidence = 0.5;

    // SCHOOL
    if (_containsAny(lowerInput, [
      'submit', 'exam', 'quiz', 'homework', 'project', 'thesis',
      'recitation', 'clearance', 'enrollment', 'aral', 'assignment',
      'school', 'klase', 'class', 'lecturer', 'professor'
    ])) {
      category = ReminderCategory.school;
      confidence = 0.9;
    }
    // WORK
    else if (_containsAny(lowerInput, [
      'meeting', 'deadline', 'report', 'client', 'email', 'presentation',
      'overtime', 'trabaho', 'office', 'work', 'sweldo', 'task', 'slack'
    ])) {
      category = ReminderCategory.work;
      confidence = 0.9;
    }
    // HEALTH
    else if (_containsAny(lowerInput, [
      'check-up', 'gamot', 'inom ng gamot', 'doctor', 'hospital',
      'vitamins', 'exercise', 'diet', 'gym', 'health', 'fitness', 'tulog'
    ])) {
      category = ReminderCategory.health;
      confidence = 0.85;
    }
    // SOCIAL
    else if (_containsAny(lowerInput, [
      'kaarawan', 'birthday', 'inuman', 'tambay', 'date', 'anniversary',
      'reunion', 'party', 'hangout', 'kita', 'gala', 'shot', 'coffee'
    ])) {
      category = ReminderCategory.social;
      confidence = 0.85;
    }
    // ERRANDS
    else if (_containsAny(lowerInput, [
      'bayad', 'bills', 'grocery', 'palengke', 'padala', 'load',
      'pickup', 'delivery', 'bili', 'utang', 'shopee', 'lazada', 'milo'
    ])) {
      category = ReminderCategory.errands;
      confidence = 0.8;
    }
    // BAHALA NA (Special Riri Category)
    else if (_containsAny(lowerInput, [
      'bahala na', 'ewan', 'di ko alam', 'whatever', 'depende'
    ])) {
      category = ReminderCategory.bahalaNa;
      confidence = 0.95;
    }

    return ParsedReminder(
      title: input.trim(),
      category: category,
      confidence: confidence,
      extractedAt: DateTime.now(),
    );
  }

  /// Backward-compatible classification method.
  ReminderCategory classify(String input) {
    return parse(input).category;
  }

  bool _containsAny(String input, List<String> keywords) {
    return keywords.any((k) => input.contains(k));
  }
}
