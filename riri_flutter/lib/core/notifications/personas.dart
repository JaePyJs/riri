import 'package:flutter/material.dart';
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

/// Houses the dedicated copywriting fields for Riri's conversational responses and completion payoffs.
class PersonaCopyData {
  final String completionHeadline;
  final String completionBody;
  final String completionButtonLabel;
  final String completionEmoji;

  /// Card confirmations and chat greetings
  final String saveButtonLabel;
  final String cancelButtonLabel;
  final String savedBannerText;
  final String cancelledBannerText;
  final String savedGreeting;
  final String cancelledGreeting;
  final String greetingWithName;
  final String greetingWithoutName;

  const PersonaCopyData({
    required this.completionHeadline,
    required this.completionBody,
    required this.completionButtonLabel,
    required this.completionEmoji,
    required this.saveButtonLabel,
    required this.cancelButtonLabel,
    required this.savedBannerText,
    required this.cancelledBannerText,
    required this.savedGreeting,
    required this.cancelledGreeting,
    required this.greetingWithName,
    required this.greetingWithoutName,
  });
}

/// Houses the complete, data-driven templates defining a single Riri Personality Profile.
class PersonaConfig {
  final PersonalityMode mode;
  final String name;
  final String description;
  final Color accentColor;
  final List<Color> confettiColors;

  /// Dedicated copywriting sub-object
  final PersonaCopyData copy;

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
    required this.accentColor,
    required this.confettiColors,
    required this.copy,
    required this.standard,
    required this.snooze,
    required this.overdue,
  });

  /// Master Registry of Riri's personas.
  static final Map<PersonalityMode, PersonaConfig> registry = {
    PersonalityMode.bestie: const PersonaConfig(
      mode: PersonalityMode.bestie,
      name: 'Barkada',
      description: '✨ Warm, hype, and casual barkada-style support.',
      accentColor: Color(0xFFC77DFF),
      confettiColors: [Color(0xFFFF6EC7), Color(0xFFC77DFF), Color(0xFFFF007F)],
      copy: PersonaCopyData(
        completionHeadline: 'Hala, Grabe! 🎉',
        completionBody: "Natapos mo rin! Ang galing mo naman, proud na proud si Riri sa'yo! ✨",
        completionButtonLabel: 'Salamat! 💖',
        completionEmoji: '🎉',
        saveButtonLabel: 'Sige, g! 🚀',
        cancelButtonLabel: 'Wag muna 💅',
        savedBannerText: 'Nakalista na, bestie! G! 🚀',
        cancelledBannerText: 'Wag muna raw... Okay, next time! 💅',
        savedGreeting: "G! Naka-schedule na yung goal mo, bestie! Tapusin natin 'to ha!",
        cancelledGreeting: 'Aww, sige next time na lang. Take it easy!',
        greetingWithName: 'Hoy, {name}! Riri here, ready to achieve our goals with you! Ano na plano natin today? ✨',
        greetingWithoutName: 'Uy, musta na? Riri here, ready to achieve our goals with you! Ano na plano natin today? ✨',
      ),
      standard: PersonaTemplate(
        title: 'Hoy! Riri here 👋',
        body: "Uy, reminder mo: {task}. Let's get it done!",
      ),
      snooze: PersonaTemplate(
        title: 'Huy! 🔔',
        body: "I-snooze mo ulit? '{task}' Hindi pa rin natin magagawa yan nang ganyan.",
      ),
      overdue: PersonaTemplate(
        title: 'Uy... 👀',
        body: "Ito na yung ika-{days} araw mo sa '{task}'. Kakayanin pa ba?",
      ),
    ),
    PersonalityMode.malupit: const PersonaConfig(
      mode: PersonalityMode.malupit,
      name: 'Malupit',
      description: '💀 Maximum roast, tough love, zero slacking tolerance.',
      accentColor: Color(0xFFFF4D6D),
      confettiColors: [Color(0xFFFF4D6D), Color(0xFF8B0000), Color(0xFFFF0000)],
      copy: PersonaCopyData(
        completionHeadline: 'Finally. 💀',
        completionBody: "Nagawa mo rin pala. Hindi ko aakalaing mangyayari 'to. Next.",
        completionButtonLabel: 'Noted. 🫡',
        completionEmoji: '💀',
        saveButtonLabel: 'I-save na. 💀',
        cancelButtonLabel: 'Katamaran 😡',
        savedBannerText: 'Naka-save na. Magtrabaho ka na. 💀',
        cancelledBannerText: 'Kinansela. Katamaran wins again. 😡',
        savedGreeting: "Naka-save na. Huwag mo nang balaking i-snooze 'yan mamaya.",
        cancelledGreeting: 'Kinansela mo. Ganyan naman palagi, puro salita, walang gawa.',
        greetingWithName: 'Riri here, {name}. Ready to do some work or are you planning to snooze all day? Speak up.',
        greetingWithoutName: 'Riri here. Ready to do some work or are you planning to snooze all day? Speak up.',
      ),
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
      accentColor: Color(0xFF48CAE4),
      confettiColors: [Color(0xFF6EFFD6), Color(0xFF48CAE4), Color(0xFF00F5D4)],
      copy: PersonaCopyData(
        completionHeadline: 'Yay, nice one~ ✌️',
        completionBody: "Done na 'yan, no stress! Take a breather and vibe. You deserve it 🍃",
        completionButtonLabel: 'Thanks bes~ 🌿',
        completionEmoji: '✌️',
        saveButtonLabel: 'Steady, save na 🍃',
        cancelButtonLabel: 'Bukas na ✌️',
        savedBannerText: 'All good, saved na~ Relax ka lang. 🍃',
        cancelledBannerText: 'No pressure, next time na lang~ ✌️',
        savedGreeting: "No pressure, saved na 'tong task natin. Steady lang.",
        cancelledGreeting: 'Chill lang, okay lang \'yan. Sunod na lang.',
        greetingWithName: 'Hey, {name}~ Riri here. Relax ka lang, everything is under control. Ano gagawin natin today? 🍃',
        greetingWithoutName: 'Hey~ Uy, musta na? Riri here. Relax ka lang, everything is under control. Ano gagawin natin today? 🍃',
      ),
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
      accentColor: Color(0xFFF4A261),
      confettiColors: [Color(0xFFFFD166), Color(0xFFF4A261), Color(0xFFE76F51)],
      copy: PersonaCopyData(
        completionHeadline: 'Ay nako, tapos na! 🙏',
        completionBody: "Ang galing mo naman anak! Kumain ka na para may lakas ka sa susunod na trabaho ha. 💜",
        completionButtonLabel: 'Opo Tita! 💜',
        completionEmoji: '🙏',
        saveButtonLabel: 'Opo Tita, save na 👵',
        cancelButtonLabel: 'Mamaya na po 👵',
        savedBannerText: 'Nailista ko na, anak. Galingan mo! 👵❤️',
        cancelledBannerText: 'Sige na nga, mamaya na lang ha anak? 👵',
        savedGreeting: 'Nailista ko na ang kailangan mong gawin, anak. Galingan mo ha.',
        cancelledGreeting: 'Sige anak, mamaya na lang kung pagod ka pa. Magpahinga ka muna ha.',
        greetingWithName: 'Kumain ka na ba, {name} anak? Riri dito. Halika, ilista natin ang kailangan mong gawin ha? 👵',
        greetingWithoutName: 'Kumain ka na ba anak? Riri dito. Halika, ilista natin ang kailangan mong gawin ha? 👵',
      ),
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
    assert(registry.containsKey(mode), 'PersonaConfig missing for mode: $mode');
    return registry[mode] ?? registry[PersonalityMode.bestie]!;
  }
}
