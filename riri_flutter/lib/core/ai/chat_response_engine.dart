import 'dart:convert';
import 'dart:math';
import '../notifications/personality_copy.dart';
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
  static final RegExp _relativeTimeSuffix = RegExp(
    r'\s+(?:in|pagkalipas\s+ng)\s+([1-9][0-9]{0,5})\s+'
    r'(minutes?|hours?|minuto|oras)\s*[.!?]*\s*$',
    caseSensitive: false,
  );

  final TaglishKeywordClassifier _classifier = TaglishKeywordClassifier();

  /// Generates a conversational response and extracts potential tasks dynamically.
  ChatResponse generateResponse({
    required String userInput,
    required PersonalityMode personalityMode,
    String? newlyLearnedName,
  }) {
    // Acknowledge learned name immediately with customized, persona-aligned responses
    if (newlyLearnedName != null && newlyLearnedName.isNotEmpty) {
      String responseText = '';
      String stickerName = 'Wink';
      switch (personalityMode) {
        case PersonalityMode.bestie:
          responseText =
              "Oh nice, $newlyLearnedName! Love the name. I'll remember that — our chika just got more personal!";
          stickerName = 'Welcoming';
          break;
        case PersonalityMode.malupit:
          responseText =
              "So you're $newlyLearnedName. Good. Now that that's settled — anong natapos mo ngayon? Speak up.";
          stickerName = 'Angry';
          break;
        case PersonalityMode.chill:
          responseText =
              "Hey $newlyLearnedName, nice to meet you. We'll keep things easy around here, no pressure.";
          stickerName = 'Inactive';
          break;
        case PersonalityMode.tita:
          responseText =
              "What a lovely name, $newlyLearnedName! I'll keep that in mind. Kumain ka na ba today? Let's make sure you're taken care of.";
          stickerName = 'Welcoming';
          break;
      }
      return ChatResponse(
        text: responseText,
        stickerName: stickerName,
      );
    }

    final lower = userInput.toLowerCase();

    // 1. Check for task creation intents dynamically via keyword parsing or classifier
    if (lower.contains('remind') ||
        lower.contains('paalala') ||
        lower.contains('reminder') ||
        lower.contains('gawin') ||
        lower.contains('ilista')) {
      final relativeTime = _relativeTimeSuffix.firstMatch(userInput);
      final extractedTitle = _cleanExtractedTitle(userInput, relativeTime);

      // Parse reminder category dynamically using the TaglishKeywordClassifier
      final parsedResult = _classifier.parse(extractedTitle);
      final category = parsedResult.category == ReminderCategory.personal &&
              parsedResult.confidence < 0.6
          ? ReminderCategory.personal
          : parsedResult.category;

      // Extract due date dynamically from natural language expressions
      final dueDateTime = _parseDueDateTime(userInput, relativeTime);

      final jsonPayload = json.encode({
        'title': extractedTitle,
        'category': category.name,
        'dueDate': dueDateTime.toIso8601String(),
        'state': 'pending',
      });

      return ChatResponse(
        text: '[TASK_CARD]$jsonPayload',
        stickerName: 'Confident_Suggestion',
        extractedTitle: extractedTitle,
        extractedCategory: category,
        extractedDueDate: dueDateTime,
      );
    }

    final random = Random();

    // --- LIFESTYLE CHIKA INTERACTIVITY & ALARM & GAME ENGINE ---

    // 1. Alarm Setting & Alarm Actions
    if (lower.contains('alarm') ||
        lower.contains('gisingin') ||
        (lower.contains('gising') &&
            !lower.contains('kamusta') &&
            !lower.contains('kumusta') &&
            !lower.contains('hoy') &&
            !lower.contains('hi') &&
            !lower.contains('hello'))) {
      final parsedTime = _tryParseAlarmTime(userInput);
      String text = '';
      String sticker = 'Wink';
      switch (personalityMode) {
        case PersonalityMode.bestie:
          text = parsedTime != null
              ? "Got it! Alarm set for $parsedTime. I'll make sure you're up and ready — walang late today!"
              : "Sure! What time do you want me to wake you up? Just say something like 'alarm 7 AM' and I'll handle the rest.";
          sticker = parsedTime != null ? 'Confident_Suggestion' : 'Wink';
          break;
        case PersonalityMode.malupit:
          text = parsedTime != null
              ? "Alarm set for $parsedTime. When it goes off — you get up. No snoozing. Wala akong pakialam sa excuses."
              : "Set your alarm. What time? Give me the exact time (e.g. 'alarm 6:00 AM') and we'll go from there.";
          sticker = 'Angry';
          break;
        case PersonalityMode.chill:
          text = parsedTime != null
              ? "Alarm is set for $parsedTime. Take your time waking up — dahan-dahan lang, no rush."
              : "Sure, I can help with an alarm. What time works for you? Just tell me (e.g. 'alarm 8 AM') whenever you're ready.";
          sticker = 'Inactive';
          break;
        case PersonalityMode.tita:
          text = parsedTime != null
              ? "Okay, I'll wake you at $parsedTime. Don't forget to sleep early tonight — wag magpuyat ha."
              : "What time do you need to wake up? Tell me and I'll set it for you. Make sure you get enough rest too.";
          sticker = 'Welcoming';
          break;
      }
      return ChatResponse(text: text, stickerName: sticker);
    }

    // 2. Rock-Paper-Scissors (Bato-Bato-Pick) Game
    if (lower.contains('laro') ||
        lower.contains('game') ||
        lower.contains('bato') ||
        lower.contains('papel') ||
        lower.contains('gunting')) {
      final bool userBato = lower.contains('bato');
      final bool userPapel = lower.contains('papel');
      final bool userGunting = lower.contains('gunting');

      if (!userBato && !userPapel && !userGunting) {
        String text = '';
        switch (personalityMode) {
          case PersonalityMode.bestie:
            text =
                "Okay, let's play! Bato-Bato-Pick — pick one: Rock, Paper, or Scissors? Go!";
            break;
          case PersonalityMode.malupit:
            text =
                "Fine. Bato-Bato-Pick. Pick now: Rock, Paper, or Scissors. Then we get back to work after.";
            break;
          case PersonalityMode.chill:
            text =
                "Sure, why not. Bato-Bato-Pick — what's your pick: Rock, Paper, or Scissors? Take your time.";
            break;
          case PersonalityMode.tita:
            text =
                "Oh, you want to play? Okay, Bato-Bato-Pick! Pick one: Rock, Paper, or Scissors?";
            break;
        }
        return ChatResponse(text: text, stickerName: 'Wink');
      } else {
        final ririChoices = ['Bato', 'Papel', 'Gunting'];
        final ririChoice = ririChoices[random.nextInt(3)];
        String userChoice =
            userBato ? 'Bato' : (userPapel ? 'Papel' : 'Gunting');
        String result = '';
        if (userChoice == ririChoice) {
          result = 'tie';
        } else if ((userChoice == 'Bato' && ririChoice == 'Gunting') ||
            (userChoice == 'Papel' && ririChoice == 'Bato') ||
            (userChoice == 'Gunting' && ririChoice == 'Papel')) {
          result = 'win';
        } else {
          result = 'lose';
        }

        String text = '';
        String sticker = 'Wink';
        switch (personalityMode) {
          case PersonalityMode.bestie:
            if (result == 'tie') {
              text =
                  "Draw! We both picked $ririChoice. Want to go again?";
            } else if (result == 'win') {
              text =
                  "You win! Your $userChoice beats my $ririChoice. Nice one!";
            } else {
              text =
                  "Ha! I win this round. My $ririChoice beats your $userChoice. Bawi ka next time!";
            }
            sticker = result == 'win' ? 'Confetti_Explosion' : 'Wink';
            break;
          case PersonalityMode.malupit:
            if (result == 'tie') {
              text =
                  "Draw. We both picked $ririChoice. Walang nanalo. Now get back to your tasks.";
            } else if (result == 'win') {
              text =
                  "You win. $userChoice beats $ririChoice. Happy now? Good. Back to work.";
            } else {
              text =
                  "You lose. My $ririChoice beats your $userChoice. Focus on winning at your tasks instead.";
            }
            sticker = 'Angry';
            break;
          case PersonalityMode.chill:
            if (result == 'tie') {
              text =
                  "Tie — we both went $ririChoice. No stress, play again whenever.";
            } else if (result == 'win') {
              text =
                  "Nice, you got it. $userChoice beats $ririChoice. Good call.";
            } else {
              text =
                  "I got this one — $ririChoice beats $userChoice. Chill lang, no big deal.";
            }
            sticker = 'Inactive';
            break;
          case PersonalityMode.tita:
            if (result == 'tie') {
              text =
                  "Ay, we're tied! We both picked $ririChoice. Want to try again?";
            } else if (result == 'win') {
              text =
                  "You won! Your $userChoice beats my $ririChoice. Ang swerte mo today!";
            } else {
              text =
                  "I win this one! My $ririChoice beats your $userChoice. Don't be sad — may I treat you pa rin!";
            }
            sticker = 'Welcoming';
            break;
        }
        return ChatResponse(text: text, stickerName: sticker);
      }
    }

    // 3. Joke / Gossip / Stories
    if (lower.contains('chika') ||
        lower.contains('kwento') ||
        lower.contains('tsismis') ||
        lower.contains('joke') ||
        lower.contains('tawa')) {
      final bestieJokes = [
        "Okay here's some chika — our neighbor has been playing loud music at 5 AM and someone finally reported it to the barangay last night. About time! Anyway, what's up with you?",
        "Quick joke: why was the calendar always sad? Because all its dates kept passing it by. Haha, okay that was bad. But still!",
        "True story — my friend stared at the ceiling for 2 hours last night 'thinking'. Pretty sure he was just avoiding his checklist. Sound familiar?"
      ];
      final chillJokes = [
        "Story time: last night I just sat back, lo-fi on, ceiling staring. Honestly, peaceful. You should try it sometime — after your tasks, though.",
        "Okay here's a joke: what do you call a banana wearing a wig? Ba-na-na-wig. I know, I know. But it made you smile a little, right?"
      ];
      final titaJokes = [
        "Oh, you want tsismis? Okay — my neighbor bought an air fryer and then burnt her lumpia on the first try. Sayang talaga. Classic. Anyway, have you eaten?",
        "Here's one: what fish always gets choked? Salmon — because it keeps trying to salmon more food. Ha! Okay, kumain ka na ha."
      ];

      String text = '';
      String sticker = 'Wink';
      switch (personalityMode) {
        case PersonalityMode.bestie:
          text = bestieJokes[random.nextInt(bestieJokes.length)];
          sticker = 'Wink';
          break;
        case PersonalityMode.malupit:
          text = random.nextBool()
              ? "I don't do chika. What I am interested in is hearing which of your tasks you actually finished today. Talk to me about that."
              : "You want a joke? Here's one: you said you'd get your tasks done, and yet here we are — chatting. Classic. Get to work.";
          sticker = 'Angry';
          break;
        case PersonalityMode.chill:
          text = chillJokes[random.nextInt(chillJokes.length)];
          sticker = 'Inactive';
          break;
        case PersonalityMode.tita:
          text = titaJokes[random.nextInt(titaJokes.length)];
          sticker = 'Welcoming';
          break;
      }
      return ChatResponse(text: text, stickerName: sticker);
    }

    // 4. Hungry / Food
    if (lower.contains('gutom') ||
        lower.contains('kain') ||
        lower.contains('food') ||
        lower.contains('lunch') ||
        lower.contains('dinner') ||
        lower.contains('breakfast') ||
        lower.contains('grab') ||
        lower.contains('panda')) {
      String text = '';
      String sticker = 'Wink';
      switch (personalityMode) {
        case PersonalityMode.bestie:
          text = random.nextBool()
              ? "Gutom ka na? Go eat! Don't hold back — your brain needs fuel to finish those tasks. Grab something good."
              : "Kain muna, then we come back to the checklist. Can't do anything properly on an empty stomach.";
          sticker = 'Confetti_Explosion';
          break;
        case PersonalityMode.malupit:
          text = random.nextBool()
              ? "Fine, go eat. But come right back after — walang tatambay. Food is fuel for getting things done, not an excuse to disappear."
              : "Gutom ka? Okay. Eat fast. You still have tasks pending and the deadline isn't moving.";
          sticker = 'Angry';
          break;
        case PersonalityMode.chill:
          text = random.nextBool()
              ? "Snack break sounds good. Recharge first, then we'll get back to things when you're ready. No rush."
              : "Go eat something — you've earned the break. We'll pick up where we left off after, steady lang.";
          sticker = 'Inactive';
          break;
        case PersonalityMode.tita:
          text = random.nextBool()
              ? "Have you eaten already? Don't skip meals, ha — it's not good for you. Eat something proper before getting back to your tasks."
              : "Naku, kumain ka na ba? You can't work properly on an empty stomach. Put the phone down and eat first. I mean it.";
          sticker = 'Welcoming';
          break;
      }
      return ChatResponse(text: text, stickerName: sticker);
    }

    // 5. Sleep / Night
    if (lower.contains('tulog') ||
        lower.contains('sleep') ||
        lower.contains('antok') ||
        lower.contains('higa')) {
      String text = '';
      String sticker = 'Wink';
      switch (personalityMode) {
        case PersonalityMode.bestie:
          text = random.nextBool()
              ? "Antok ka na? Get some rest! We'll pick up what's left tomorrow. Sleep well and dream of a finished checklist."
              : "Go to bed, charge your phone, and actually rest. Fresh mind tomorrow means better work — trust the process.";
          sticker = 'Inactive';
          break;
        case PersonalityMode.malupit:
          text = random.nextBool()
              ? "Going to sleep? Make sure you actually did something useful today first. If not, that's on you. Tulog na."
              : "Antok? Of course you are. Anyway — tomorrow, walang babagal-bagal. Be ready to move when you wake up.";
          sticker = 'Angry';
          break;
        case PersonalityMode.chill:
          text = random.nextBool()
              ? "Get some rest, you've done enough for today. We'll sort the rest out tomorrow — tulog na."
              : "Goodnight. Switch off, relax, let everything settle. Everything will still be here mañana.";
          sticker = 'Inactive';
          break;
        case PersonalityMode.tita:
          text = random.nextBool()
              ? "Sleep early, ha? Wag magpuyat — it's bad for your health. Drink some water first, then get some proper rest."
              : "You worked hard today. Higa na and sleep well. I'll check in with you tomorrow morning, ha.";
          sticker = 'Inactive';
          break;
      }
      return ChatResponse(text: text, stickerName: sticker);
    }

    String responseText = '';
    String stickerName = 'Wink';

    switch (personalityMode) {
      case PersonalityMode.bestie:
        if (lower.contains('hi') ||
            lower.contains('hello') ||
            lower.contains('hoy') ||
            lower.contains('kamusta') ||
            lower.contains('kumusta')) {
          final replies = [
            'Hey! Ready when you are. How is your day going?',
            'Hello! Hope things are going well. Anything on your mind or any tasks we need to set up?',
            'Oh hey! Musta na? What are we working on today?',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Welcoming';
        } else if (lower.contains('salamat') ||
            lower.contains('thanks') ||
            lower.contains('thank you')) {
          final replies = [
            "Walang anuman! Glad I could help. What else do you need?",
            "Of course! Always here for you. Now let's get those tasks moving.",
            "Happy to help. You're doing great — keep that momentum going.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Confetti_Explosion';
        } else if (lower.contains('tired') ||
            lower.contains('pagod') ||
            lower.contains('lungkot') ||
            lower.contains('sad') ||
            lower.contains('stress')) {
          final replies = [
            "Hey, that's okay. Pagod is normal — take a proper break before pushing through. You don't have to do everything at once.",
            "It's alright to slow down. Rest first, then we take it one step at a time. No pressure.",
            "Stressed ka? Deep breath muna. Let's figure out what's actually urgent and let the rest wait.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Inactive';
        } else if (lower.contains('love') ||
            lower.contains('mahal') ||
            lower.contains('cute')) {
          final replies = [
            "Appreciate it! Now let's channel that energy into crushing those tasks.",
            "Thanks for the love! Let's make today a productive one.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Wink';
        } else {
          final replies = [
            "Got it! Sounds like a lot going on. Want to add any of that to your task list?",
            "Interesting! Anyway, whenever you're ready — I'm here to help you stay on track.",
            "I hear you. Let's make sure the important things actually get done today.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Wink';
        }
        break;

      case PersonalityMode.malupit:
        if (lower.contains('hi') ||
            lower.contains('hello') ||
            lower.contains('hoy') ||
            lower.contains('kamusta') ||
            lower.contains('kumusta')) {
          final replies = [
            "You're saying hi but have you checked your task list today? Focus.",
            "No small talk. What have you actually finished today?",
            "Kumusta? I'm stressed watching you waste time. Let's go.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Angry';
        } else if (lower.contains('salamat') ||
            lower.contains('thanks') ||
            lower.contains('thank you')) {
          final replies = [
            "Save the thanks. Just finish what's on your list and don't snooze.",
            "You can thank me by actually completing your tasks. Now move.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Angry';
        } else if (lower.contains('tired') ||
            lower.contains('pagod') ||
            lower.contains('lungkot') ||
            lower.contains('sad') ||
            lower.contains('stress')) {
          final replies = [
            "Everyone's tired. That's not a reason to stop. Keep going.",
            "Drama. You're stressed because you procrastinated. Fix it — start with the first task.",
            "Pagod? Rest for 10 minutes, then back to work. No extended breaks.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Angry';
        } else if (lower.contains('love') ||
            lower.contains('mahal') ||
            lower.contains('cute')) {
          final replies = [
            "I'll believe that when your task list is empty. Work first.",
            "Words are cheap. Show me progress, not compliments.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Angry';
        } else {
          final replies = [
            "Stop chatting and check your dashboard. The clock is ticking.",
            "If you spent half as much time on your tasks as you do talking, you'd be done by now. Kilos.",
            "The deadline doesn't care about your conversation. Let's go.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Angry';
        }
        break;

      case PersonalityMode.chill:
        if (lower.contains('hi') ||
            lower.contains('hello') ||
            lower.contains('hoy') ||
            lower.contains('kamusta') ||
            lower.contains('kumusta')) {
          final replies = [
            "Hey. All good here. Kumusta ka? No rush — whenever you're ready to start.",
            "Low-key today is fine. Just checking in — anything you need to get sorted?",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Inactive';
        } else if (lower.contains('salamat') ||
            lower.contains('thanks') ||
            lower.contains('thank you')) {
          final replies = [
            "No worries at all. We'll get through things at your own pace.",
            "Easy — that's what I'm here for. Steady lang.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Inactive';
        } else if (lower.contains('tired') ||
            lower.contains('pagod') ||
            lower.contains('lungkot') ||
            lower.contains('sad') ||
            lower.contains('stress')) {
          final replies = [
            "Take a real break — pagod is a signal to slow down, not push harder. Rest muna.",
            "That's okay. Breathe. You don't have to figure it all out right now.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Inactive';
        } else if (lower.contains('love') ||
            lower.contains('mahal') ||
            lower.contains('cute')) {
          responseText =
              "Good vibes only. Appreciate it — enjoy the rest of your day.";
          stickerName = 'Wink';
        } else {
          final replies = [
            "That sounds like a lot. Take it one thing at a time — steady lang.",
            "No rush. When you're ready, let's figure out what to tackle first.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Wink';
        }
        break;

      case PersonalityMode.tita:
        if (lower.contains('hi') ||
            lower.contains('hello') ||
            lower.contains('hoy') ||
            lower.contains('kamusta') ||
            lower.contains('kumusta')) {
          final replies = [
            "Hello! Kumain ka na ba? Don't skip meals — what can I help you with today?",
            "Kumusta? Hope you're doing well. Let me know if there's anything on your mind or your list.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Welcoming';
        } else if (lower.contains('salamat') ||
            lower.contains('thanks') ||
            lower.contains('thank you')) {
          final replies = [
            "Walang anuman — I'm always here to help you out. Keep it up, ha.",
            "Of course! That's what I'm here for. Take care of yourself, ha.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Confetti_Explosion';
        } else if (lower.contains('tired') ||
            lower.contains('pagod') ||
            lower.contains('lungkot') ||
            lower.contains('sad') ||
            lower.contains('stress')) {
          final replies = [
            "Naku, have you been sleeping properly? Drink some water and rest muna — your health comes first.",
            "I hear you. Stressed is not a good place to be. Take a proper break, then we'll tackle what's left together.",
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Inactive';
        } else if (lower.contains('love') ||
            lower.contains('mahal') ||
            lower.contains('cute')) {
          responseText =
              "Ay, mahal din kita! Look after yourself, ha — and don't forget to check your reminders.";
          stickerName = 'Wink';
        } else {
          final replies = [
            "I see. Let's make a note of that so nothing gets forgotten, ha.",
            "Okay, okay. Tell me more — I'll help you figure out what to handle first.",
          ];
          responseText = replies[random.nextInt(replies.length)];
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
  DateTime _parseDueDateTime(String input, RegExpMatch? relativeTime) {
    final now = DateTime.now();
    if (relativeTime != null) {
      final amount = int.parse(relativeTime.group(1)!);
      final unit = relativeTime.group(2)!.toLowerCase();
      final delay = unit.startsWith('hour') || unit == 'oras'
          ? Duration(hours: amount)
          : Duration(minutes: amount);
      return now.add(delay);
    }

    final lower = input.toLowerCase();
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

    if (lower.contains('tonight') ||
        lower.contains('mamayang gabi') ||
        lower.contains('gabi')) {
      return DateTime(now.year, now.month, now.day, 20, 0);
    }

    if (lower.contains('later') || lower.contains('mamaya')) {
      return now.add(const Duration(hours: 2));
    }

    // Default to 4 hours as a fallback
    return now.add(const Duration(hours: 4));
  }



  /// Cleans the user input to extract a clean task title.
  String _cleanExtractedTitle(String input, RegExpMatch? relativeTime) {
    String title = relativeTime == null
        ? input
        : input.substring(0, relativeTime.start);

    // 1. Remove intent/prefix patterns
    final prefixes = [
      r'remind me to',
      r'paalala mo',
      r'pakilista',
      r'ilista',
      r'gawin',
      r'reminder to',
    ];
    for (final prefix in prefixes) {
      title =
          title.replaceAll(RegExp('\\b$prefix\\b', caseSensitive: false), '');
    }

    // 2. Remove time/date phrases
    final timePhrases = [
      r'tomorrow morning',
      r'tomorrow afternoon',
      r'tomorrow evening',
      r'tomorrow',
      r'bukas ng umaga',
      r'bukas ng hapon',
      r'bukas ng gabi',
      r'bukas',
      r'next week',
      r'susunod na linggo',
      r'mamayang gabi',
      r'tonight',
      r'mamaya',
      r'later',
      r'ng umaga',
      r'ng hapon',
      r'ng gabi',
    ];
    // Calendar words can be part of the task when it has an explicit delay.
    if (relativeTime == null) {
      for (final phrase in timePhrases) {
        title =
            title.replaceAll(RegExp('\\b$phrase\\b', caseSensitive: false), '');
      }
    }

    // 3. Remove filler words
    final fillers = [
      r'natin',
      r'nga',
      r'naman',
      r'po',
      r'mga',
      r'ko',
      r'mo',
      r'sa',
      r'at',
    ];
    for (final filler in fillers) {
      title =
          title.replaceAll(RegExp('\\b$filler\\b', caseSensitive: false), '');
    }

    // Clean up extra whitespaces
    title = title.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (title.isEmpty) {
      title = 'New Task';
    }

    return title;
  }

  /// Extracts user's name if they introduce themselves in Taglish or English.
  String? tryExtractName(String message) {
    final lower = message.toLowerCase().trim();

    final patterns = [
      RegExp(r'\bako\s+(?:nga\s+pala\s+|pala\s+)?si\s+([a-zA-Z0-9]+)\b'),
      RegExp(r'\btawagin\s+mo\s+akong\s+([a-zA-Z0-9]+)\b'),
      RegExp(r'\btawagin\s+mo\s+ako\s+si\s+([a-zA-Z0-9]+)\b'),
      RegExp(r'\bmy\s+name\s+is\s+([a-zA-Z0-9]+)\b'),
      RegExp(r"\bi\s+am\s+([a-zA-Z0-9]+)\b"),
      RegExp(r"\bi'm\s+([a-zA-Z0-9]+)\b"),
      RegExp(r"\bim\s+([a-zA-Z0-9]+)\b"),
      RegExp(r'\bpangalan\s+ko\s+(?:ay|si)\s+([a-zA-Z0-9]+)\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(lower);
      if (match != null) {
        final nameLower = match.group(1)!;
        // Find index in lower to extract original casing from message
        final start = lower.indexOf(nameLower);
        if (start != -1 && start + nameLower.length <= message.length) {
          final extracted =
              message.substring(start, start + nameLower.length).trim();
          if (extracted.isNotEmpty) {
            return _capitalize(extracted);
          }
        }
        return _capitalize(nameLower);
      }
    }
    return null;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String? _tryParseAlarmTime(String input) {
    final lower = input.toLowerCase();
    final timeRegex = RegExp(r'\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b');
    final match = timeRegex.firstMatch(lower);
    if (match != null) {
      final hour = match.group(1)!;
      final minute = match.group(2) ?? '00';
      final period = match.group(3) ?? '';
      return "$hour:$minute ${period.toUpperCase()}".trim();
    }
    return null;
  }
}
