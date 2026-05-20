enum ReminderCategory {
  school,
  work,
  health,
  social,
  errands,
  personal,
  bahalaNa;

  // Convert to String for DB storage
  String toDbValue() => name;

  // Read from DB storage
  static ReminderCategory fromDbValue(String value) {
    return ReminderCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReminderCategory.personal,
    );
  }

  // Display label in dynamic Taglish
  String get taglishLabel {
    switch (this) {
      case ReminderCategory.school:
        return 'Schoolwork 📚';
      case ReminderCategory.work:
        return 'Trabaho/Office 💼';
      case ReminderCategory.health:
        return 'Health/Gym 💊';
      case ReminderCategory.social:
        return 'Tambay/Date 🍻';
      case ReminderCategory.errands:
        return 'Bili/Lakad 🛒';
      case ReminderCategory.personal:
        return 'Personal/Chill 🧸';
      case ReminderCategory.bahalaNa:
        return 'Bahala Na Mode 🫡';
    }
  }
}

enum ProcrastinationLevel {
  none,
  medium,
  high,
  bahalaNa;

  String get taglishWarning {
    switch (this) {
      case ProcrastinationLevel.none:
        return 'Good job, solid discipline!';
      case ProcrastinationLevel.medium:
        return 'Huy, gumalaw ka na konti, baka ma-late tayo.';
      case ProcrastinationLevel.high:
        return 'Grabe ka na makapag-snooze ah, anong plano?';
      case ProcrastinationLevel.bahalaNa:
        return 'Sige na nga, bahala ka na sa buhay mo! 🫡';
    }
  }
}
