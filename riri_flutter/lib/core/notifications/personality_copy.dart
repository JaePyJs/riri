import 'personas.dart';

enum PersonalityMode {
  bestie,
  malupit,
  chill,
  tita;

  // Convert to String for DB/Prefs storage
  String toDbValue() => name;

  // Read from DB/Prefs storage
  static PersonalityMode fromDbValue(String value) {
    return PersonalityMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PersonalityMode.bestie,
    );
  }

  // Label to show in settings page
  String get displayLabel {
    switch (this) {
      case PersonalityMode.bestie:
        return '✨ Barkada (Supportive & Friendly - Default)';
      case PersonalityMode.malupit:
        return '💀 Malupit (Maximum Roast / Tough Love)';
      case PersonalityMode.chill:
        return '🍃 Chill (Low Pressure / Low Stress)';
      case PersonalityMode.tita:
        return '👵 Tita (Nagging but caring & traditional)';
    }
  }
}

class PersonalityNotificationCopy {
  
  /// Formats notification titles and bodies dynamically from data template configurations.
  static Map<String, String> getNotificationText({
    required PersonalityMode mode,
    required String reminderTitle,
    required int snoozeCount,
    required int daysOverdue,
  }) {
    final persona = PersonaConfig.get(mode);
    final params = {
      'task': reminderTitle,
      'days': daysOverdue.toString(),
      'snoozeCount': snoozeCount.toString(),
    };

    PersonaTemplate selectedTemplate;
    if (daysOverdue >= 3) {
      selectedTemplate = persona.overdue;
    } else if (snoozeCount >= 2) {
      selectedTemplate = persona.snooze;
    } else {
      selectedTemplate = persona.standard;
    }

    return {
      'title': selectedTemplate.renderTitle(params),
      'body': selectedTemplate.renderBody(params),
    };
  }
}
