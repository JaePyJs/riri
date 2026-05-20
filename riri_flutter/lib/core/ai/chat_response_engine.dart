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
  final TaglishKeywordClassifier _classifier = TaglishKeywordClassifier();

  /// Generates a conversational response and extracts potential tasks dynamically.
  ChatResponse generateResponse({
    required String userInput,
    required PersonalityMode personalityMode,
    String? newlyLearnedName,
  }) {
    // Acknowledge learned name immediately with customized, persona-aligned responses!
    if (newlyLearnedName != null && newlyLearnedName.isNotEmpty) {
      String responseText = '';
      String stickerName = 'Wink';
      switch (personalityMode) {
        case PersonalityMode.bestie:
          responseText =
              "Hala! So $newlyLearnedName pala pangalan mo! Ang ganda naman! Sige, tatandaan ko 'yan para special ang chika natin! 😉✨";
          stickerName = 'Welcoming';
          break;
        case PersonalityMode.malupit:
          responseText =
              "So, ikaw pala si $newlyLearnedName. Mabuti naman at nagpakilala ka. Ngayon, magtrabaho ka na at huwag kang tamad.";
          stickerName = 'Angry';
          break;
        case PersonalityMode.chill:
          responseText =
              "Oh, hello $newlyLearnedName~ Nice name. Relax lang tayo ha, no stress. 🍃";
          stickerName = 'Inactive';
          break;
        case PersonalityMode.tita:
          responseText =
              "Napakagandang pangalan naman, $newlyLearnedName! Sige, tatandaan ni Tita Riri 'yan para gabayan kita nang mabuti. Kumain ka na ba? 👵";
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
      String extractedTitle = _cleanExtractedTitle(userInput);

      // Parse reminder category dynamically using the TaglishKeywordClassifier!
      final parsedResult = _classifier.parse(extractedTitle);
      final category = parsedResult.category == ReminderCategory.personal &&
              parsedResult.confidence < 0.6
          ? ReminderCategory.personal
          : parsedResult.category;

      // Extract due date dynamically from natural language expressions!
      final dueDateTime = _parseDueDateTime(userInput);

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
              ? "Hala sige! Naka-set na alarm mo ng $parsedTime. Babulabugin kita para di ka late, gising talaga kung gising! ⏰🔔"
              : "Sure! Ano'ng oras kita gigisingin? Sabihin mo lang sa akin yung time (e.g. 'alarm 7 AM') tapos ako na bahala! ⏰";
          sticker = parsedTime != null ? 'Confident_Suggestion' : 'Wink';
          break;
        case PersonalityMode.malupit:
          text = parsedTime != null
              ? "Naka-set na ang alarm sa $parsedTime. Kapag natulog ka pa pagkatapos nyan, ewan ko na lang sa'yo. Gising agad!"
              : "Magset ka ng alarm. Anong oras? Isulat mo ang eksaktong oras (e.g. 'alarm 6:00 AM') para magising ka.";
          sticker = 'Angry';
          break;
        case PersonalityMode.chill:
          text = parsedTime != null
              ? "Sige~ alarm is set sa $parsedTime. Dahan-dahan lang ang gising ha, walang pressure. 🍃⏰"
              : "Sige, gisingin kita. Anong oras mo ba gusto? Sabihin mo lang (e.g. 'alarm 8 AM')~ 🍃";
          sticker = 'Inactive';
          break;
        case PersonalityMode.tita:
          text = parsedTime != null
              ? "Naku, opo. Gisingin kita ng $parsedTime ha? Mag-alarm ka rin sa tabi mo para sigurado. Wag magpuyat! 👵⏰"
              : "Anong oras kita gigisingin? Sabihin mo kay Tita Riri yung oras para ma-set natin. 👵";
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
                "Ay gayan! Bato-Bato-Pick tayo! Dali, pumili ka: Bato, Papel, or Gunting? Taya na! ✊✋✌️";
            break;
          case PersonalityMode.malupit:
            text =
                "Laro? Sige, Bato-Bato-Pick. Pumili ka ngayon din: Bato, Papel, o Gunting. Pagkatapos nito, balik trabaho.";
            break;
          case PersonalityMode.chill:
            text =
                "G~ laro tayo ng Bato-Bato-Pick. Ano taya mo: Bato, Papel, o Gunting? Relax lang~ 🍃";
            break;
          case PersonalityMode.tita:
            text =
                "Ay gusto mo maglaro? Sige, Bato-Bato-Pick tayo! Ano ang taya mo: Bato, Papel, o Gunting? 👵";
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
                  "Draw! Pareho tayong $ririChoice! Bato-Bato-Pick ulit! ✊✋✌️";
            } else if (result == 'win') {
              text =
                  "Hala panalo ka! Pinili ko $ririChoice tapos $userChoice sa'yo. Ang galing mo naman! 🏆🎉";
            } else {
              text =
                  "Yahoo! Talo ka! Pinili ko $ririChoice tapos $userChoice sa'yo. Bawi na lang next time! 😂🤪";
            }
            sticker = result == 'win' ? 'Confetti_Explosion' : 'Wink';
            break;
          case PersonalityMode.malupit:
            if (result == 'tie') {
              text =
                  "Patas. Pareho tayong $ririChoice. Walang kwenta ang tabla, mag-focus ka na lang sa trabaho mo.";
            } else if (result == 'win') {
              text =
                  "Nanalo ka. Pinili ko $ririChoice at $userChoice sa'yo. Congrats. Ngayong masaya ka na, kilos na sa tasks.";
            } else {
              text =
                  "Talo ka. Pinili ko $ririChoice laban sa $userChoice mo. Walang puwang ang talunan, mag-seryoso ka na.";
            }
            sticker = 'Angry';
            break;
          case PersonalityMode.chill:
            if (result == 'tie') {
              text =
                  "Tie tayo~ Pareho tayong $ririChoice. Bawi na lang next time pag may time~ 🍃";
            } else if (result == 'win') {
              text =
                  "Nice, panalo ka~ $userChoice mo beats $ririChoice ko. Galing mo dun ah. 🍃";
            } else {
              text =
                  "Talo ka but it's okay~ $ririChoice ko beats $userChoice mo. Chill lang. 🌙";
            }
            sticker = 'Inactive';
            break;
          case PersonalityMode.tita:
            if (result == 'tie') {
              text =
                  "Ay tabla! Parehong $ririChoice ang taya natin. Ulitin ba natin? 👵";
            } else if (result == 'win') {
              text =
                  "Naku ang galing naman, panalo ka! $userChoice mo laban sa $ririChoice ni Tita. Ang swerte mo ngayon ha! 👵💖";
            } else {
              text =
                  "Ay talo ka ng tita mo! Pinili ko $ririChoice tapos $userChoice naman sa'yo. May pa-consolation prize ka sa akin na kiss! 👵🥰";
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
        "Chika ba? Alam mo ba yung kapitbahay natin na laging nagpapatugtog ng budots ng 5 AM? Ayun, nireklamo sa barangay kagabi! Chika ulit mamaya pag tapos ka na ha! 🤫🤐",
        "Joke time! Bakit malungkot ang kalendaryo? Kasi marami siyang dates pero lahat lumilipas lang. Aruy! Haha! 😂",
        "May kwento ako! Yung aso namin nakatitig sa pader kaninang madaling araw. Feeling ko may kausap na multo. Kaya ikaw, wag ka papabuyo sa procrastination baka multuhin ka! 👻"
      ];
      final chillJokes = [
        "Kwento ba? Solid nung nakaraang gabi, nakatitig lang ako sa kisame habang nakikinig sa lo-fi. Peaceful lang. Sali ka next time~ 🍃",
        "Joke tayo. Anong tawag sa saging na nakasuot ng wig? Eh di... Ba-na-na-wig. Relax lang, tawa ka na please~ 🌙"
      ];
      final titaJokes = [
        "Naku, may tsismis si Tita sa'yo. Alam mo ba si Mareng Susan, bumili ng bagong air fryer tapos nasunog yung lumpia nya kahapon! Sayang talaga. 👵",
        "Joke ba? Anong isda ang laging nabubulunan? Eh di... Salmon! Kasi sal-mon ng sal-mon ng pagkain! Haha, kain ka na ha? 👵🥰"
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
              ? "Chika? Wala akong time sa tsismis. Mas interesado akong marinig kung kailan mo matatapos yang mga nakatambak mong gagawin."
              : "Gusto mo ng joke? Ang pinakamalaking joke rito ay yung sinabi mong gagawin mo na tasks mo pero heto ka pa rin, nakikipagdaldalan sa akin. Magtrabaho ka.";
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
              ? "Hala gutom ka na? Kain na dali! Wag mo tipirin ang sarili mo sa Grab ha. Samahan mo na rin ng milk tea! 🧋🍔"
              : "Kain na! Mahirap mag-focus kapag walang laman ang tyan. Sabay tayo next time pag natapos na tasks natin! 🍕🍟";
          sticker = 'Confetti_Explosion';
          break;
        case PersonalityMode.malupit:
          text = random.nextBool()
              ? "Gutom ka na naman? Puro ka kain, wala ka pa ngang natatapos na task. Sige, kumain ka pero mag-focus ka pagkatapos!"
              : "Kain na kung kakain, pero wag kang tatambay pagkatapos. Kain para may lakas mag-check ng checklist. Bawal tamad!";
          sticker = 'Angry';
          break;
        case PersonalityMode.chill:
          text = random.nextBool()
              ? "Kain na tayo~ Safe lagyan ng snacks ang table para high energy. Kape or tea? Steady lang. 🍃🍔"
              : "Snack break muna, deserved mo yan. Relax ka lang habang kumakain tapos g ulit mamaya. 🌙🍜";
          sticker = 'Inactive';
          break;
        case PersonalityMode.tita:
          text = random.nextBool()
              ? "Kumain ka na ba? Naku, wag na wag mong lilipasan ang gutom mo ha! Ipagluluto kita ng masarap na sinigang kung malapit lang ako. Kain na dali! 👵🍲"
              : "Kumain ka na ng tanghalian/hapunan ha? Masama sa tyan ang magpalipas ng gutom. Iwan muna ang ginagawa at kumain na ng masustansya! 👵🍚";
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
              ? "Antok ka na? Sige higa na! Bukas na natin habulin yung iba. Goodnight at matulog ng mahimbing! 🛌💤"
              : "Sleep well! I-charge mo na rin phone mo at matulog ng maaga para fresh bukas! Dream of your success! 🌙😴";
          sticker = 'Inactive';
          break;
        case PersonalityMode.malupit:
          text = random.nextBool()
              ? "Matutulog ka na naman? Siguraduhin mong nagawa mo lahat ng nakalista ngayon ha. Kung hindi, konsensya mo na lang yan. Sige, tulog na."
              : "Antok? Ganyan talaga kapag tamad. Sige na, matulog ka na pero bukas bawal ang babagal-bagal. Kilos agad paggising!";
          sticker = 'Angry';
          break;
        case PersonalityMode.chill:
          text = random.nextBool()
              ? "Higa na, take a break~ Napagod ka din today. Dream peaceful dreams, see you tomorrow. 🍃💤"
              : "Goodnight~ turn off the lights, relax and rest. Everything is handled. 🌙😴";
          sticker = 'Inactive';
          break;
        case PersonalityMode.tita:
          text = random.nextBool()
              ? "Naku, matulog ka na ha? Bawal magpuyat at masama yan sa kalusugan mo. Inom ka muna ng maligamgam na tubig bago matulog. Goodnight! 👵💤"
              : "Higa na at magpahinga. Napaka-hardworking mo naman today. Sleep well at gigisingin kita bukas ha? 👵😴";
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
            'Hoy! Handang-handa na ako rito. Kumusta ang araw natin? ✨',
            'Hello! Kape muna tapos checklist completed na ba? Ready to achieve our goals today? ☕',
            'Yow! Ano’ng ganap natin today? May ipapaalala ka ba? 📣',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Welcoming';
        } else if (lower.contains('salamat') ||
            lower.contains('thanks') ||
            lower.contains('thank you')) {
          final replies = [
            'Walang anuman! Basta para sa\'yo, easy lang yan. Kape tayo next! ☕',
            'Luh, maliit na bagay! Proud of you! 💖',
            'Basta para sa\'yo, anytime! Kayang-kaya natin \'to! 🎉',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Confetti_Explosion';
        } else if (lower.contains('tired') ||
            lower.contains('pagod') ||
            lower.contains('lungkot') ||
            lower.contains('sad') ||
            lower.contains('stress')) {
          final replies = [
            'Aww, felt! Okay lang mapagod, pero bawal sumuko! Pahinga ka muna tapos game ulit! 💕',
            'Huy, okay lang yan! Mahirap talaga minsan, pero laban lang. Break muna sandali tapos simulan natin ulit. ☕',
            'Naku, sino ba nagpapastress sa\'yo? Char! Pahinga ka muna sandali para refresh. 🥰',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Inactive';
        } else if (lower.contains('love') ||
            lower.contains('mahal') ||
            lower.contains('cute')) {
          final replies = [
            'Omsim! Salamat sa support! Let\'s get these goals! 💪',
            'Yieee, thank you! Let\'s get this done na para masaya! 🎉',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Wink';
        } else {
          final replies = [
            'Narinig kita! Solid nyan, pero focus din tayo sa reminders natin ha? 💪',
            'Oyyy totoo ba? Grabe talaga! Sige na, tapusin na natin \'tong tasks para chill na later! 🚀',
            'Kuwentuhan tayo mamaya pagkatapos, subukan muna natin tapusin yung tasks natin today! 👍',
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
            'Bakit ka bumabati? May natapos ka na bang task? Focus.',
            'Walang hi-hi dito. Trabaho muna. Sayang ang oras.',
            'Kumusta? Heto, naiistress sa kabagalan mo. Galaw-galaw!',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Angry';
        } else if (lower.contains('salamat') ||
            lower.contains('thanks') ||
            lower.contains('thank you')) {
          final replies = [
            'No need for thanks. Just finish your work and don\'t snooze.',
            'Pasalamat ka kapag natapos mo na lahat. Sa ngayon, upo at mag-focus.',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Angry';
        } else if (lower.contains('tired') ||
            lower.contains('pagod') ||
            lower.contains('lungkot') ||
            lower.contains('sad') ||
            lower.contains('stress')) {
          final replies = [
            'Pagod? Everyone is. Get up and get to work. No excuses.',
            'Drama mo. Ang tunay na malakas, walang time mapagod. Tapusin mo na yan.',
            'Stressed? Dahil sa procrasti-nation mo yan. Gumawa ka kasi agad!',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Angry';
        } else if (lower.contains('love') ||
            lower.contains('mahal') ||
            lower.contains('cute')) {
          final replies = [
            'Huwag mo akong daanin sa matatamis na salita. Magtrabaho ka.',
            'Love? Mas mahal ko kapag tapos ang tasks mo. Kaya gumalaw ka.',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Angry';
        } else {
          final replies = [
            'Stop chatting and check your dashboard. Time is ticking.',
            'Kung ganyan karami ang nasasabi mo, sana ganyan din kabilis matapos tasks mo. Kilos!',
            'Wag puro daldal. Ang deadline malapit na, ikaw tambay pa rin.',
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
            'Hey~ Chill lang tayo today, no pressure. Kumusta? 🍃',
            'Low-key day ngayon. Relax ka lang, dahan-dahan nating simulan. 🌙',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Inactive';
        } else if (lower.contains('salamat') ||
            lower.contains('thanks') ||
            lower.contains('thank you')) {
          final replies = [
            'No worries~ take your time, everything is fine. 🌙',
            'Chill lang, easy as it goes. Glad I could help. 🍃',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Inactive';
        } else if (lower.contains('tired') ||
            lower.contains('pagod') ||
            lower.contains('lungkot') ||
            lower.contains('sad') ||
            lower.contains('stress')) {
          final replies = [
            'Pahinga ka muna bes, deserved mo yan. Bukas na natin isipin ang iba. 🍃',
            'Okay lang mag-slow down. Breath in, breath out. We\'ve got time. 🌙',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Inactive';
        } else if (lower.contains('love') ||
            lower.contains('mahal') ||
            lower.contains('cute')) {
          responseText =
              'Thanks, simple happiness right here. Keep enjoying your day. 🍃';
          stickerName = 'Wink';
        } else {
          final replies = [
            'Ganyan talaga ang life. Relax ka lang, magagawa din natin yan. 🌙',
            'Take a deep breath. No rush, steady lang ang pacing natin today. 🍃',
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
            'Hello! Kumain ka na ba? Wag kang magpapakapagod masyado ha? 👵',
            'Naku, kumusta naman ang araw mo? May kailangan ka ba? 🍲',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Welcoming';
        } else if (lower.contains('salamat') ||
            lower.contains('thanks') ||
            lower.contains('thank you')) {
          final replies = [
            'Walang anuman, basta mag-aral kang mabuti ha. Proud ako sayo! ✨',
            'Siyempre naman, laging nandito si Tita para gabayan ka. ✨',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Confetti_Explosion';
        } else if (lower.contains('tired') ||
            lower.contains('pagod') ||
            lower.contains('lungkot') ||
            lower.contains('sad') ||
            lower.contains('stress')) {
          final replies = [
            'Hala, uminom ka ba ng maraming tubig? Matulog ka nang maaga ha, huwag magpuyat. 👵',
            'Naku, stress? Ipagluluto kita ng sopas o kaya champorado. Higa ka muna sandali. 🍲',
          ];
          responseText = replies[random.nextInt(replies.length)];
          stickerName = 'Inactive';
        } else if (lower.contains('love') ||
            lower.contains('mahal') ||
            lower.contains('cute')) {
          responseText =
              'Mahal din kita! Laging mag-iingat sa pagtawid ha. 👵';
          stickerName = 'Wink';
        } else {
          final replies = [
            'Naku, ganun ba? Basta palaging magdadasal at mag-iingat ha. ✨',
            'Ilista natin yan para hindi mo malimutan, mahirap na makalimot katulad ni Tita. 👵',
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
  String _cleanExtractedTitle(String input) {
    String title = input;

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
    for (final phrase in timePhrases) {
      title =
          title.replaceAll(RegExp('\\b$phrase\\b', caseSensitive: false), '');
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
      title = 'Special Task ✨';
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
