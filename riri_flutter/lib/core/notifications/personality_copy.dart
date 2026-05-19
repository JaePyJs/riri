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
        return '💅 Bestie (Supportive & Witty - Default)';
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
  static Map<String, String> getNotificationText({
    required PersonalityMode mode,
    required String reminderTitle,
    required int snoozeCount,
    required int daysOverdue,
  }) {
    String title;
    String body;

    switch (mode) {
      case PersonalityMode.bestie:
        if (daysOverdue >= 3) {
          title = 'Bestie... 👀';
          body = "Ito na yung ika-$daysOverdue araw mo sa '$reminderTitle'. Kakayanin pa ba?";
        } else if (snoozeCount >= 2) {
          title = 'Huy! 🔔';
          body = "I-snooze mo ulit? '$reminderTitle' Hindi pa rin natin magagawa yan nang ganyan.";
        } else {
          title = 'Hoy! Riri here 👋';
          body = "Uy, reminder mo: $reminderTitle. Let's get it done!";
        }
        break;

      case PersonalityMode.malupit:
        if (daysOverdue >= 3) {
          title = 'Day $daysOverdue. Seriously? 💀';
          body = "'$reminderTitle'. I have literally nothing more to say to you.";
        } else {
          title = 'Get up. 🔔';
          body = "'$reminderTitle'. Now. Or suffer the consequences.";
        }
        break;

      case PersonalityMode.chill:
        title = 'Hey, no rush ✌️';
        body = "Just checking — $reminderTitle when you have the energy.";
        break;

      case PersonalityMode.tita:
        title = 'Anak, naalala mo ba? 🙏';
        body = "Yung '$reminderTitle' mo, hindi pa tapos. Gawin mo na bago ka pa makalimot ulit, naku.";
        break;
    }

    return {'title': title, 'body': body};
  }
}
