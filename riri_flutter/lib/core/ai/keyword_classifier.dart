import 'ai_models.dart';

class TaglishKeywordClassifier {
  ReminderCategory classify(String input) {
    final lowerInput = input.toLowerCase();

    // SCHOOL
    if (_containsAny(lowerInput, [
      'submit', 'exam', 'quiz', 'homework', 'project', 'thesis',
      'recitation', 'clearance', 'enrollment', 'aral', 'assignment',
      'school', 'klase', 'class', 'lecturer', 'professor'
    ])) {
      return ReminderCategory.school;
    }

    // WORK
    if (_containsAny(lowerInput, [
      'meeting', 'deadline', 'report', 'client', 'email', 'presentation',
      'overtime', 'trabaho', 'office', 'work', 'sweldo', 'task', 'slack'
    ])) {
      return ReminderCategory.work;
    }

    // HEALTH
    if (_containsAny(lowerInput, [
      'check-up', 'gamot', 'inom ng gamot', 'doctor', 'hospital',
      'vitamins', 'exercise', 'diet', 'gym', 'health', 'fitness', 'tulog'
    ])) {
      return ReminderCategory.health;
    }

    // SOCIAL
    if (_containsAny(lowerInput, [
      'kaarawan', 'birthday', 'inuman', 'tambay', 'date', 'anniversary',
      'reunion', 'party', 'hangout', 'kita', 'gala', 'shot', 'coffee'
    ])) {
      return ReminderCategory.social;
    }

    // ERRANDS
    if (_containsAny(lowerInput, [
      'bayad', 'bills', 'grocery', 'palengke', 'padala', 'load',
      'pickup', 'delivery', 'bili', 'utang', 'shopee', 'lazada', 'milo'
    ])) {
      return ReminderCategory.errands;
    }

    // BAHALA NA (Special Riri Category)
    if (lowerInput.contains('bahala na') || 
        lowerInput.contains('ewan') || 
        lowerInput.contains('di ko alam') || 
        lowerInput.contains('whatever') || 
        lowerInput.contains('depende')) {
      return ReminderCategory.bahalaNa;
    }

    return ReminderCategory.personal;
  }

  bool _containsAny(String input, List<String> keywords) {
    return keywords.any((k) => input.contains(k));
  }
}
