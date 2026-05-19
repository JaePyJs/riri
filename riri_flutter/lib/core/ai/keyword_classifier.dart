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
    
    // Score all categories dynamically using key keyword lists
    final Map<ReminderCategory, double> scores = {
      ReminderCategory.school: _scoreCategory(lowerInput, [
        'submit', 'exam', 'quiz', 'homework', 'project', 'thesis',
        'recitation', 'clearance', 'enrollment', 'aral', 'assignment',
        'school', 'klase', 'class', 'lecturer', 'professor'
      ]),
      ReminderCategory.work: _scoreCategory(lowerInput, [
        'meeting', 'deadline', 'report', 'client', 'email', 'presentation',
        'overtime', 'trabaho', 'office', 'work', 'sweldo', 'task', 'slack'
      ]),
      ReminderCategory.health: _scoreCategory(lowerInput, [
        'check-up', 'gamot', 'inom ng gamot', 'doctor', 'hospital',
        'vitamins', 'exercise', 'diet', 'gym', 'health', 'fitness', 'tulog'
      ]),
      ReminderCategory.social: _scoreCategory(lowerInput, [
        'kaarawan', 'birthday', 'inuman', 'tambay', 'date', 'anniversary',
        'reunion', 'party', 'hangout', 'kita', 'gala', 'shot', 'coffee'
      ]),
      ReminderCategory.errands: _scoreCategory(lowerInput, [
        'bayad', 'bills', 'grocery', 'palengke', 'padala', 'load',
        'pickup', 'delivery', 'bili', 'utang', 'shopee', 'lazada', 'milo'
      ]),
      ReminderCategory.bahalaNa: _scoreCategory(lowerInput, [
        'bahala na', 'ewan', 'di ko alam', 'whatever', 'depende'
      ]),
    };

    // Detect highest matching score
    ReminderCategory bestCategory = ReminderCategory.personal;
    double highestScore = 0.0;

    scores.forEach((category, score) {
      if (score > highestScore) {
        highestScore = score;
        bestCategory = category;
      }
    });

    // Compute dynamic, proportional confidence score based on match specificity density
    double confidence = 0.5;
    if (highestScore > 0.0) {
      // Scale dynamic confidence score between 0.6 and 0.99
      confidence = (0.6 + (highestScore * 0.39)).clamp(0.6, 0.99);
    }

    return ParsedReminder(
      title: input.trim(),
      category: bestCategory,
      confidence: confidence,
      extractedAt: DateTime.now(),
    );
  }

  /// Backward-compatible classification method.
  ReminderCategory classify(String input) {
    return parse(input).category;
  }

  /// Calculates the weight density of matching terms relative to keyword library size.
  double _scoreCategory(String input, List<String> keywords) {
    final matchedKeywords = keywords.where((k) => input.contains(k)).toList();
    if (matchedKeywords.isEmpty) return 0.0;
    
    // Density calculation: matches relative to vocabulary length
    final double density = matchedKeywords.length / keywords.length;
    
    // Weight matches: single matching word gives baseline 0.6, additional matches push it up
    return (0.4 + (density * 0.6)).clamp(0.0, 1.0);
  }
}
