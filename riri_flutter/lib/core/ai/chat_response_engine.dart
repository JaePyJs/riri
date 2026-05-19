import '../persistence/riri_repository.dart';
import '../persistence/riri_database.dart';
import '../notifications/personality_copy.dart';
import '../notifications/personas.dart';
import 'ai_models.dart';
import 'keyword_classifier.dart';

class ChatResponse {
  final String text;
  final String stickerName;
  final String? extractedTitle;
  final ReminderCategory? extractedCategory;
  final DateTime? extractedDueDate;

  const ChatResponse({
    required this.text,
    required this.stickerName,
    this.extractedTitle,
    this.extractedCategory,
    this.extractedDueDate,
  });
}

class ChatResponseEngine {
  final TaglishKeywordClassifier _classifier = TaglishKeywordClassifier();

  /// Generates a conversational response and extracts potential tasks dynamically.
  ChatResponse generateResponse({
    required String userInput,
    required PersonalityMode personalityMode,
  }) {
    final lower = userInput.toLowerCase();
    final persona = PersonaConfig.get(personalityMode);

    // 1. Check for task creation intents dynamically via keyword parsing or classifier
    if (lower.contains('remind') || 
        lower.contains('paalala') || 
        lower.contains('reminder') ||
        lower.contains('gawin') || 
        lower.contains('ilista')) {
      
      String extractedTitle = userInput
          .replaceAll(RegExp(r'(remind me to|paalala mo|pakilista|ilista|gawin|reminder to)', caseSensitive: false), '')
          .trim();
      
      if (extractedTitle.isEmpty) extractedTitle = 'Special Task ✨';

      // Parse reminder category dynamically using the TaglishKeywordClassifier!
      final parsedResult = _classifier.parse(extractedTitle);
      final category = parsedResult.category == ReminderCategory.personal && parsedResult.confidence < 0.6
          ? ReminderCategory.personal
          : parsedResult.category;

      // Extract due date dynamically from natural language expressions!
      final dueDateTime = _parseDueDateTime(userInput);

      // Render standard template dynamically from the Persona Registry!
      final String confirmationText = _renderTaskCreationConfirmation(
        personalityMode: personalityMode,
        taskTitle: extractedTitle,
      );

      return ChatResponse(
        text: confirmationText,
        stickerName: 'Confident_Suggestion',
        extractedTitle: extractedTitle,
        extractedCategory: category,
        extractedDueDate: dueDateTime,
      );
    }

    // 2. Map standard chika chat responses using data-driven persona styling
    String responseText = '';
    String stickerName = 'Wink';

    switch (personalityMode) {
      case PersonalityMode.bestie:
        if (lower.contains('hi') || lower.contains('hello') || lower.contains('hoy')) {
          responseText = 'Hoy din bestie! Handang-handa na ako rito. Ready to take over? 💅';
          stickerName = 'Welcoming';
        } else if (lower.contains('salamat') || lower.contains('thanks')) {
          responseText = 'Naku, you\'re welcome! Basta ikaw, gagawin natin lahat! Iced coffee next? ☕';
          stickerName = 'Confetti_Explosion';
        } else if (lower.contains('tired') || lower.contains('pagod')) {
          responseText = 'Aww, felt! Okay lang mapagod bestie, pero bawal sumuko! Rest ka muna tapos game ulit! 💕';
          stickerName = 'Inactive';
        } else {
          responseText = 'Narinig kita! Sobrang solid nyan bestie, pero focus din tayo sa mga reminders ha? 💪';
          stickerName = 'Wink';
        }
        break;

      case PersonalityMode.malupit:
        if (lower.contains('hi') || lower.contains('hello')) {
          responseText = 'Bakit ka bumabati? May natapos ka na bang task? Focus.';
          stickerName = 'Angry';
        } else if (lower.contains('salamat') || lower.contains('thanks')) {
          responseText = 'No need for thanks. Just finish your work and don\'t snooze.';
          stickerName = 'Angry';
        } else if (lower.contains('tired') || lower.contains('pagod')) {
          responseText = 'Pagod? Everyone is. Get up and get to work. No excuses.';
          stickerName = 'Angry';
        } else {
          responseText = 'Stop chatting and check your dashboard. Time is ticking.';
          stickerName = 'Angry';
        }
        break;

      case PersonalityMode.chill:
        if (lower.contains('hi') || lower.contains('hello')) {
          responseText = 'Hey bestie~ Chill lang tayo today, no pressure. Kamusta? 🍃';
          stickerName = 'Inactive';
        } else if (lower.contains('salamat') || lower.contains('thanks')) {
          responseText = 'No worries~ take your time, everything is fine. 🌙';
          stickerName = 'Inactive';
        } else if (lower.contains('tired') || lower.contains('pagod')) {
          responseText = 'Pahinga ka muna bestie, deserved mo yan. Bukas na natin isipin ang iba. 🍃';
          stickerName = 'Inactive';
        } else {
          responseText = 'Ganyan talaga ang life. Relax ka lang, magagawa din natin yan. 🌙';
          stickerName = 'Wink';
        }
        break;

      case PersonalityMode.tita:
        if (lower.contains('hi') || lower.contains('hello')) {
          responseText = 'Hello anak! Kumain ka na ba? Wag kang magpapakapagod masyado ha? 👵';
          stickerName = 'Welcoming';
        } else if (lower.contains('salamat') || lower.contains('thanks')) {
          responseText = 'Walang anuman anak, basta mag-aral kang mabuti ha. Proud ako sayo! ✨';
          stickerName = 'Confetti_Explosion';
        } else if (lower.contains('tired') || lower.contains('pagod')) {
          responseText = 'Hala anak, uminom ka ba ng maraming tubig? Matulog ka nang maaga ha, huwag magpuyat. 👵';
          stickerName = 'Inactive';
        } else {
          responseText = 'Naku anak, ganun ba? Basta palaging magdadasal at mag-iingat ha. ✨';
          stickerName = 'Wink';
        }
        break;
    }

    return ChatResponse(
      text: responseText,
      stickerName: stickerName,
    );
  }

  /// Parses simple time triggers inside natural language expressions dynamically.
  DateTime _parseDueDateTime(String input) {
    final lower = input.toLowerCase();
    final now = DateTime.now();
    
    if (lower.contains('tomorrow') || lower.contains('bukas')) {
      final tomorrow = now.add(const Duration(days: 1));
      if (lower.contains('morning') || lower.contains('umaga')) {
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
      }
      if (lower.contains('afternoon') || lower.contains('hapon')) {
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0);
      }
      if (lower.contains('evening') || lower.contains('gabi')) {
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 19, 0);
      }
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 0);
    }
    
    if (lower.contains('next week') || lower.contains('susunod na linggo')) {
      return now.add(const Duration(days: 7));
    }
    
    if (lower.contains('tonight') || lower.contains('mamayang gabi') || lower.contains('gabi')) {
      return DateTime(now.year, now.month, now.day, 20, 0);
    }
    
    if (lower.contains('later') || lower.contains('mamaya')) {
      return now.add(const Duration(hours: 2));
    }
    
    // Default to 4 hours as a fallback
    return now.add(const Duration(hours: 4));
  }

  /// Renders standard confirmation text leveraging the registered templates.
  String _renderTaskCreationConfirmation({
    required PersonalityMode personalityMode,
    required String taskTitle,
  }) {
    final persona = PersonaConfig.get(personalityMode);
    
    // Render the standard persona layout to keep copy fully data-driven as the primary response!
    return persona.standard.renderBody({'task': taskTitle});
  }
}
