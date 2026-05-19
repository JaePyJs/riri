import 'personality_copy.dart';

/// Represents a dynamic copy template row supporting variable interpolation.
class PersonaTemplate {
  final String title;
  final String body;

  const PersonaTemplate({
    required this.title,
    required this.body,
  });

  /// Substitutes parameter placeholders (e.g., `{task}`, `{days}`) with concrete runtime values.
  String renderTitle(Map<String, String> params) => _render(title, params);
  String renderBody(Map<String, String> params) => _render(body, params);

  String _render(String source, Map<String, String> params) {
    String output = source;
    params.forEach((key, value) {
      output = output.replaceAll('{$key}', value);
    });
    return output;
  }
}

/// Houses the complete, data-driven templates defining a single Riri Personality Profile.
class PersonaConfig {
  final PersonalityMode mode;
  final String name;
  final String description;

  /// Default notification template
  final PersonaTemplate standard;

  /// Snoozed reminder templates
  final PersonaTemplate snooze;

  /// Overdue reminder templates
  final PersonaTemplate overdue;

  const PersonaConfig({
    required this.mode,
    required this.name,
    required this.description,
    required this.standard,
    required this.snooze,
    required this.overdue,
  });

  /// Master Registry of Riri's personas.
  static final Map<PersonalityMode, PersonaConfig> registry = {
    PersonalityMode.bestie: const PersonaConfig(
      mode: PersonalityMode.bestie,
      name: 'Bestie',
      description: '💅 Warm, hype, and full of Gen Z friendly support.',
      standard: PersonaTemplate(
        title: 'Hoy! Riri here 👋',
        body: "Uy, reminder mo: {task}. Let's get it done!",
      ),
      snooze: PersonaTemplate(
        title: 'Huy! 🔔',
        body: "I-snooze mo ulit? '{task}' Hindi pa rin natin magagawa yan nang ganyan.",
      ),
      overdue: PersonaTemplate(
        title: 'Bestie... 👀',
        body: "Ito na yung ika-{days} araw mo sa '{task}'. Kakayanin pa ba?",
      ),
    ),
    PersonalityMode.malupit: const PersonaConfig(
      mode: PersonalityMode.malupit,
      name: 'Malupit',
      description: '💀 Maximum roast, tough love, zero slacking tolerance.',
      standard: PersonaTemplate(
        title: 'Get up. 🔔',
        body: "'{task}'. Now. Or suffer the consequences.",
      ),
      snooze: PersonaTemplate(
        title: 'Seriously? 💀',
        body: "Pang-ilang snooze na 'yan sa '{task}'? Umayos ka nga.",
      ),
      overdue: PersonaTemplate(
        title: 'Day {days}. Seriously? 💀',
        body: "'{task}'. I have literally nothing more to say to you.",
      ),
    ),
    PersonalityMode.chill: const PersonaConfig(
      mode: PersonalityMode.chill,
      name: 'Chill',
      description: '🍃 Low-pressure, low stress, and relaxed vibrations.',
      standard: PersonaTemplate(
        title: 'Hey, no rush ✌️',
        body: "Just checking — {task} when you have the energy.",
      ),
      snooze: PersonaTemplate(
        title: 'Take your time 🍃',
        body: "Snoozed '{task}'. Relax bes, no hard deadlines here.",
      ),
      overdue: PersonaTemplate(
        title: 'No pressure at all bes 🍂',
        body: "Just a soft nudge for '{task}' whenever you're ready.",
      ),
    ),
    PersonalityMode.tita: const PersonaConfig(
      mode: PersonalityMode.tita,
      name: 'Tita',
      description: '👵 Maternal nagging, traditional wisdom, and genuine worry.',
      standard: PersonaTemplate(
        title: 'Anak, naalala mo ba? 🙏',
        body: "Yung '{task}' mo, hindi pa tapos. Gawin mo na bago ka pa makalimot ulit, naku.",
      ),
      snooze: PersonaTemplate(
        title: 'Naku naman... 🤦‍♀️',
        body: "I-snooze mo na naman? Baka mapuyat ka na nyan kaka-snooze sa '{task}'.",
      ),
      overdue: PersonaTemplate(
        title: 'Jusko anak... 👵',
        body: "{days} araw na 'yan na nakabinbin. Mag-vitamins ka muna bago mo asikasuhin 'tong '{task}'.",
      ),
    ),
  };

  /// Fetches a registered persona layout dynamically.
  static PersonaConfig get(PersonalityMode mode) {
    return registry[mode] ?? registry[PersonalityMode.bestie]!;
  }
}
