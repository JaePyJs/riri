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
      description: 'Warm, hype, and casual barkada-style support.',
      accentColor: Color(0xFFC77DFF),
      confettiColors: [Color(0xFFFF6EC7), Color(0xFFC77DFF), Color(0xFFFF007F)],
      copy: PersonaCopyData(
        completionHeadline: 'Yes, you did it!',
        completionBody: "You actually finished it — Riri is proud of you. Keep that energy going!",
        completionButtonLabel: 'Thanks, Riri!',
        completionEmoji: '🎉',
        saveButtonLabel: 'Save it!',
        cancelButtonLabel: 'Not now',
        savedBannerText: "Saved and ready to go, bestie! Let's get it done.",
        cancelledBannerText: 'No worries, we can pick it up next time.',
        savedGreeting: "Your goal is set — let's tackle it together.",
        cancelledGreeting: "Okay, easy. We'll get it next time. Take it easy.",
        greetingWithName: "Hey, {name}! Riri here, ready to help you stay on track. What's the plan today?",
        greetingWithoutName: "Hey there! Riri here. How are you? What are we working on today?",
      ),
      standard: PersonaTemplate(
        title: 'Riri here!',
        body: "Quick reminder: {task}. You got this — let's get it done.",
      ),
      snooze: PersonaTemplate(
        title: 'Heads up!',
        body: "You snoozed '{task}' again. We need to actually do this one, not just push it around.",
      ),
      overdue: PersonaTemplate(
        title: 'Still pending...',
        body: "It's been {days} days on '{task}'. When are we doing this? Let's set a real time for it.",
      ),
    ),
    PersonalityMode.malupit: const PersonaConfig(
      mode: PersonalityMode.malupit,
      name: 'Malupit',
      description: 'Maximum roast, tough love, zero slacking tolerance.',
      accentColor: Color(0xFFFF4D6D),
      confettiColors: [Color(0xFFFF4D6D), Color(0xFF8B0000), Color(0xFFFF0000)],
      copy: PersonaCopyData(
        completionHeadline: 'Finally done.',
        completionBody: "Took a while, but you did it. Don't make a habit of cutting it that close.",
        completionButtonLabel: 'Got it.',
        completionEmoji: '💀',
        saveButtonLabel: 'Save. Done.',
        cancelButtonLabel: 'Bailed again.',
        savedBannerText: "Saved. Now actually do it this time.",
        cancelledBannerText: "Cancelled. Again. Classic.",
        savedGreeting: "Saved. No excuses. Do it before the deadline.",
        cancelledGreeting: "Cancelled. Walang gawa, puro cancel. Sort it out.",
        greetingWithName: "Riri here, {name}. Ready to actually do some work today, or are you just warming up your excuses?",
        greetingWithoutName: "Riri here. Let's skip the small talk — are you doing your tasks today or not?",
      ),
      standard: PersonaTemplate(
        title: 'Get moving.',
        body: "'{task}'. Right now. Stop stalling.",
      ),
      snooze: PersonaTemplate(
        title: 'Seriously?',
        body: "How many times have you snoozed '{task}'? Stop pushing it. Do it.",
      ),
      overdue: PersonaTemplate(
        title: '{days} days overdue.',
        body: "'{task}'. I literally have nothing more to say about this. Just do it.",
      ),
    ),
    PersonalityMode.chill: const PersonaConfig(
      mode: PersonalityMode.chill,
      name: 'Chill',
      description: 'Low-pressure, low stress, and relaxed vibrations.',
      accentColor: Color(0xFF48CAE4),
      confettiColors: [Color(0xFF6EFFD6), Color(0xFF48CAE4), Color(0xFF00F5D4)],
      copy: PersonaCopyData(
        completionHeadline: 'Nice, that one is done.',
        completionBody: "Done na 'yan. Take a breath, you've earned it. Ready when you are for the next one.",
        completionButtonLabel: 'Thanks!',
        completionEmoji: '✌️',
        saveButtonLabel: 'Save it',
        cancelButtonLabel: 'Not today',
        savedBannerText: "Saved. No rush — whenever you're ready.",
        cancelledBannerText: "No pressure. Come back to it whenever you like.",
        savedGreeting: "Task saved. Take your time with it — steady lang.",
        cancelledGreeting: "All good. Come back when you're ready.",
        greetingWithName: "Hey, {name}. Riri here — no stress, just checking in. What are we working on today?",
        greetingWithoutName: "Hey. Riri here. Nothing urgent, just here whenever you need a hand.",
      ),
      standard: PersonaTemplate(
        title: 'No rush, just a reminder.',
        body: "When you have the energy — '{task}' is still waiting on you.",
      ),
      snooze: PersonaTemplate(
        title: 'Take your time.',
        body: "Snoozed '{task}' again. Steady lang — just don't let it fall off the radar.",
      ),
      overdue: PersonaTemplate(
        title: 'Soft nudge.',
        body: "'{task}' is still pending. No pressure, but worth revisiting soon.",
      ),
    ),
    PersonalityMode.tita: const PersonaConfig(
      mode: PersonalityMode.tita,
      name: 'Tita',
      description: 'Warm, maternal care — gentle nagging and real concern.',
      accentColor: Color(0xFFF4A261),
      confettiColors: [Color(0xFFFFD166), Color(0xFFF4A261), Color(0xFFE76F51)],
      copy: PersonaCopyData(
        completionHeadline: 'Oh, you finished it!',
        completionBody: "Well done! Make sure you eat something now, you need to keep your energy up for the next one.",
        completionButtonLabel: 'Will do!',
        completionEmoji: '🙏',
        saveButtonLabel: 'Save it now',
        cancelButtonLabel: 'Maybe later',
        savedBannerText: "All noted. Galingan mo ha — you can do this.",
        cancelledBannerText: "Okay, rest for a bit. But we'll pick this up again soon.",
        savedGreeting: "I've added that to your list. Take care of it when you can, ha.",
        cancelledGreeting: "Okay, magpahinga ka muna. We'll come back to it soon.",
        greetingWithName: "Have you eaten, {name}? Riri here. Let's look at what needs to get done today, ha?",
        greetingWithoutName: "Musta? Have you eaten yet? Riri here — let's see what's on your plate today.",
      ),
      standard: PersonaTemplate(
        title: 'Just a reminder, ha.',
        body: "Don't forget '{task}'. Take care of it before it slips your mind.",
      ),
      snooze: PersonaTemplate(
        title: 'Again?',
        body: "You snoozed '{task}' again. Okay lang, but you'll lose sleep worrying about it later.",
      ),
      overdue: PersonaTemplate(
        title: 'Naku, {days} days already.',
        body: "'{task}' has been waiting. Mag-vitamins ka muna, then let's finish this.",
      ),
    ),
  };

  /// Fetches a registered persona layout dynamically.
  static PersonaConfig get(PersonalityMode mode) {
    assert(registry.containsKey(mode), 'PersonaConfig missing for mode: $mode');
    return registry[mode] ?? registry[PersonalityMode.bestie]!;
  }
}
