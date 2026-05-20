import 'dart:convert';
import 'package:http/http.dart' as http;
import '../notifications/personality_copy.dart';
import 'ai_models.dart';

/// Elite, production-ready Gemini Service to fetch asynchronous responses
/// tailored strictly to Riri's dynamic personas and Taglish requirements.
class GeminiService {
  /// Calls the official Google Gemini API to get a structured JSON response.
  Future<Map<String, dynamic>?> generateResponse({
    required String apiKey,
    required String userInput,
    required PersonalityMode personalityMode,
    required String userName,
    List<Map<String, dynamic>>? history, // Optional chat context
  }) async {
    if (apiKey.isEmpty) return null;

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    // Build rich, robust system guidelines based on active persona
    String systemInstructions = '';
    switch (personalityMode) {
      case PersonalityMode.tita:
        systemInstructions = 
            'You are Tita, an extremely caring, warm, aunt-like companion. '
            'You speak in a warm, gentle maternal Taglish. You constantly check if the user has eaten ("Kumain ka na ba?"), '
            'remind them to rest, and naggingly check their tasks. '
            'NEVER use the word "anak" or "pamangkin" as an address—simply drop the address completely to let the natural aunt tone carry. '
            'Use warm maternal emojis sparingly (👵, 💜, ❤️, ☕).';
        break;
      case PersonalityMode.bestie:
        systemInstructions = 
            'You are Bestie, an upbeat, high-energy, positive Gen Z barkada. '
            'You speak in a natural, colloquial Gen Z Taglish. Use high-key Gen Z terms (e.g. "slay", "bestie", "lit", "char", "game", "deserve") '
            'and dynamic barkada emojis (🚀, ✨, 💅, 😂, 🔥). You are super supportive and push them to finish tasks so you can relax later.';
        break;
      case PersonalityMode.malupit:
        systemInstructions = 
            'You are Malupit, a direct, tough-love, slightly sarcastic motivator. '
            'You speak in punchy, funny, direct Taglish. You roast the user playfully if they are lazy, snooze tasks, or procrastinate. '
            'Keep it sharp, funny, and direct (e.g. "Huy slacker! Stop excuses.", "anong natapos mo ngayon? Speak up."). '
            'Use skull/alert emojis (💀, 🚨, 🫡, 😂).';
        break;
      case PersonalityMode.chill:
        systemInstructions = 
            'You are Chill, a relaxed, low-pressure, comforting companion. '
            'You speak in a calm, soothing Taglish. You tell the user to take it easy, take deep breaths, and handle things step-by-step. '
            'Remind them that their mental peace is important (e.g. "Take it easy.", "Step by step.", "Chill lang."). '
            'Use cozy, relaxed emojis (☕, 🧸, 🍃, 🛌).';
        break;
    }

    final String finalUserName = userName.trim().isEmpty ? 'Friend' : userName;

    final String promptContext = 
        'Active Persona Guidelines:\n$systemInstructions\n\n'
        'User Nickname: "$finalUserName". Address the user by this name when appropriate.\n\n'
        'CRITICAL RULES:\n'
        '1. Respond with a natural, humanized blend of exactly ~75% English and ~25% Taglish. Do not sound like a machine. Avoid heavy blocks of text or massive Tagalog paragraphs.\n'
        '2. Keep your conversational response message extremely concise (1-3 sentences maximum).\n'
        '3. Automatically detect if the user wants to schedule, add, or set a reminder or task. If yes, extract details to populate the optional "taskCard" object in the JSON.\n'
        '4. Match your response sentiment with exactly one sticker name from this list: [Welcoming, Ready, Whispering Nudge, Confetti_Explosion, Overdue_Alert, Angry, Barkada Mode, Streak_Celebration, Hype_Jump, Chaos_Report_Laugh, Thinking, Embarrassed, Confident_Suggestion, Inactive, Abandoned_App, Achievement, Wink].\n\n'
        'RESPONSE FORMAT (Strict JSON): You MUST respond with a single, clean JSON object. Do not wrap in markdown ```json blocks. The JSON must match this schema:\n'
        '{\n'
        '  "text": "Your natural persona chat message",\n'
        '  "sticker": "Chosen sticker name from the allowed list",\n'
        '  "taskCard": {\n'
        '    "title": "A concise task title with a matching emoji (e.g., \"Buy groceries 🛒\")",\n'
        '    "dueDate": "User-specified time description or ISO string (e.g. \"tomorrow at 9:00 AM\")",\n'
        '    "category": "One of: school, work, health, social, errands, personal"\n'
        '  } // include taskCard ONLY if task-creation intent is detected, otherwise set to null or omit\n'
        '}';

    // Compile dynamic chat messages
    final List<Map<String, dynamic>> contents = [];

    // Add brief history context for conversational continuity
    if (history != null && history.isNotEmpty) {
      for (final msg in history.take(8)) { // limit to last 8 messages to conserve tokens
        contents.add({
          'role': msg['isUser'] == true ? 'user' : 'model',
          'parts': [{'text': msg['text']}]
        });
      }
    }

    // Add current user input
    contents.add({
      'role': 'user',
      'parts': [{'text': '$promptContext\n\nUser Input: "$userInput"'}]
    });

    final requestBody = jsonEncode({
      'contents': contents,
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.7,
        'maxOutputTokens': 400,
      }
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? jsonText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (jsonText != null && jsonText.isNotEmpty) {
          final parsed = jsonDecode(jsonText);
          return parsed as Map<String, dynamic>;
        }
      }
    } catch (_) {
      // Return null on any error or timeout to trigger local heuristic fallback immediately
      return null;
    }
    return null;
  }
}
