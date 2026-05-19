import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/ai/ai_models.dart';
import '../../core/persistence/riri_repository.dart';
import '../../core/notifications/personality_copy.dart';
import '../../theme/riri_theme.dart';

class ChatScreen extends StatefulWidget {
  final RiriRepository repository;

  const ChatScreen({Key? key, required this.repository}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<RiriChatMessage> _messages = [];
  bool _isTyping = false;
  PersonalityMode _personalityMode = PersonalityMode.bestie;

  @override
  void initState() {
    super.initState();
    _loadPersonalityAndHistory();
  }

  Future<void> _loadPersonalityAndHistory() async {
    final mode = await widget.repository.getPersonalityMode();
    setState(() {
      _personalityMode = mode;
      _messages = widget.repository.chatHistory;
    });

    if (_messages.isEmpty) {
      _sendRiriGreeting();
    }
  }

  void _sendRiriGreeting() {
    String greeting;
    switch (_personalityMode) {
      case PersonalityMode.bestie:
        greeting = 'Hoy bestie! Riri here, ready to slay the day with you! Ano na plano natin today? ✨';
        break;
      case PersonalityMode.malupit:
        greeting = 'Riri here. Ready to do some work or are you planning to snooze all day? Speak up.';
        break;
      case PersonalityMode.chill:
        greeting = 'Hey bestie~ Riri here. Relax ka lang, everything is under control. Ano gagawin natin today? 🍃';
        break;
      case PersonalityMode.tita:
        greeting = 'Kumain ka na ba anak? Riri dito. Halika, ilista natin ang kailangan mong gawin ha? 👵';
        break;
    }

    widget.repository.addChatMessage(
      text: greeting,
      isUser: false,
      stickerName: _personalityMode == PersonalityMode.malupit ? 'Angry' : 'Welcoming',
    );

    setState(() {
      _messages = widget.repository.chatHistory;
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    widget.repository.addChatMessage(
      text: text,
      isUser: true,
    );

    setState(() {
      _messages = widget.repository.chatHistory;
      _isTyping = true;
    });

    _scrollToBottom();

    Timer(const Duration(milliseconds: 1000), () {
      final response = _generateResponse(text);
      widget.repository.addChatMessage(
        text: response,
        isUser: false,
        stickerName: _determineSticker(response),
      );

      if (mounted) {
        setState(() {
          _messages = widget.repository.chatHistory;
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
  }

  String _generateResponse(String input) {
    final lower = input.toLowerCase();

    // Check for inline task definitions
    if (lower.contains('remind') || 
        lower.contains('paalala') || 
        lower.contains('reminder') ||
        lower.contains('gawin') || 
        lower.contains('ilista')) {
      
      String extractedTitle = input
          .replaceAll(RegExp(r'(remind me to|paalala mo|pakilista|ilista|gawin|reminder to)', caseSensitive: false), '')
          .trim();
      
      if (extractedTitle.isEmpty) extractedTitle = 'Special Task ✨';

      widget.repository.addReminder(
        title: extractedTitle,
        category: ReminderCategory.personal,
        dueDateTime: DateTime.now().add(const Duration(hours: 4)),
      );

      switch (_personalityMode) {
        case PersonalityMode.bestie:
          return 'Naka-set na bestie! "$extractedTitle" is added! Check mo sa dashboard! 💅';
        case PersonalityMode.malupit:
          return 'Fine. "$extractedTitle" has been saved. Don\'t slack off.';
        case PersonalityMode.chill:
          return 'Relax ka lang, nailista ko na: "$extractedTitle". ✨';
        case PersonalityMode.tita:
          return 'Naku anak, nalista ko na: "$extractedTitle". Alagaan mo ang sarili mo ha? 🙏';
      }
    }

    // Standard responses based on current personality mode
    switch (_personalityMode) {
      case PersonalityMode.bestie:
        if (lower.contains('hi') || lower.contains('hello') || lower.contains('hoy')) {
          return 'Hoy din bestie! Handang-handa na ako rito. Ready to take over? 💅';
        }
        if (lower.contains('salamat') || lower.contains('thanks')) {
          return 'Naku, you\'re welcome! Basta ikaw, gagawin natin lahat! Iced coffee next? ☕';
        }
        if (lower.contains('tired') || lower.contains('pagod')) {
          return 'Aww, felt! Okay lang mapagod bestie, pero bawal sumuko! Rest ka muna tapos game ulit! 💕';
        }
        return 'Narinig kita! Sobrang solid nyan pero focus din tayo sa mga reminders ha? 💪';

      case PersonalityMode.malupit:
        if (lower.contains('hi') || lower.contains('hello')) {
          return 'Bakit ka bumabati? May natapos ka na bang task? Focus.';
        }
        if (lower.contains('salamat') || lower.contains('thanks')) {
          return 'No need for thanks. Just finish your work and don\'t snooze.';
        }
        if (lower.contains('tired') || lower.contains('pagod')) {
          return 'Pagod? Everyone is. Get up and get to work. No excuses.';
        }
        return 'Stop chatting and check your dashboard. Time is ticking.';

      case PersonalityMode.chill:
        if (lower.contains('hi') || lower.contains('hello')) {
          return 'Hey bestie~ Chill lang tayo today, no pressure. Kamusta? 🍃';
        }
        if (lower.contains('salamat') || lower.contains('thanks')) {
          return 'No worries~ take your time, everything is fine. 🌙';
        }
        if (lower.contains('tired') || lower.contains('pagod')) {
          return 'Pahinga ka muna bestie, deserved mo yan. Bukas na natin isipin ang iba. 🍃';
        }
        return 'Ganyan talaga ang life. Relax ka lang, magagawa din natin yan. 🌙';

      case PersonalityMode.tita:
        if (lower.contains('hi') || lower.contains('hello')) {
          return 'Hello anak! Kumain ka na ba? Wag kang magpapakapagod masyado ha? 👵';
        }
        if (lower.contains('salamat') || lower.contains('thanks')) {
          return 'Walang anuman anak, basta mag-aral kang mabuti ha. Proud ako sayo! ✨';
        }
        if (lower.contains('tired') || lower.contains('pagod')) {
          return 'Hala anak, uminom ka ba ng maraming tubig? Matulog ka nang maaga ha, huwag magpuyat. 👵';
        }
        return 'Naku anak, ganun ba? Basta palaging magdadasal at mag-iingat ha. ✨';
    }
  }

  String _determineSticker(String response) {
    final lower = response.toLowerCase();
    if (lower.contains('galit') || lower.contains('no excuses') || lower.contains('stop chatting')) {
      return 'Angry';
    }
    if (lower.contains('salamat') || lower.contains('slay') || lower.contains('proud')) {
      return 'Confetti_Explosion';
    }
    if (lower.contains('pahinga') || lower.contains('rest') || lower.contains('chill')) {
      return 'Inactive';
    }
    if (lower.contains('set na') || lower.contains('naka-set')) {
      return 'Confident_Suggestion';
    }
    return 'Wink';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _clearChatHistory() async {
    await widget.repository.clearChatHistory();
    setState(() {
      _messages = [];
    });
    _sendRiriGreeting();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: RiriTheme.darkBg,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: RiriTheme.primaryPurple.withOpacity(0.2),
              child: const Text('🌸', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Riri',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _personalityMode.displayLabel.split(' ')[1] + ' Mode Active 💅',
                  style: const TextStyle(
                    color: RiriTheme.secondaryAmber,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: RiriTheme.textSecondary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: RiriTheme.cardBg,
                  title: const Text('Clear Chat?'),
                  content: const Text('Gusto mo ba burahin yung memories natin bestie? 🥺'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Wag muna', style: TextStyle(color: RiriTheme.textMuted)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearChatHistory();
                      },
                      child: const Text('Bura na 💔', style: TextStyle(color: RiriTheme.dangerRed)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background elegant top glow gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [RiriTheme.primaryPurple.withOpacity(0.12), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _messages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _ChatBubble(message: msg);
                  },
                ),
              ),

              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'Riri is typing...',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: RiriTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: RiriTheme.cardBg,
                  border: Border(
                    top: BorderSide(color: Color(0xFF2F2F4A), width: 1.0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: RiriTheme.darkBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2F2F4A), width: 1.0),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Chika ka lang dito bestie...',
                            hintStyle: TextStyle(color: RiriTheme.textMuted, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            filled: false,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RiriTheme.brandGradient,
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final RiriChatMessage message;

  const _ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!message.isUser) ...[
          if (message.stickerName != null) ...[
            Image.asset(
              'assets/stickers/${message.stickerName}.png',
              width: 44,
              height: 44,
              errorBuilder: (context, error, stackTrace) {
                return CircleAvatar(
                  radius: 20,
                  backgroundColor: RiriTheme.primaryPurple.withOpacity(0.2),
                  child: const Icon(Icons.face, color: RiriTheme.primaryPurple, size: 20),
                );
              },
            ),
          ] else ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: RiriTheme.primaryPurple.withOpacity(0.2),
              child: const Icon(Icons.face, color: RiriTheme.primaryPurple, size: 20),
            ),
          ],
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: message.isUser ? null : RiriTheme.brandGradient,
              color: message.isUser ? const Color(0xFF2B2B3F) : null,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(message.isUser ? 20 : 0),
                bottomRight: Radius.circular(message.isUser ? 0 : 20),
              ),
              border: message.isUser
                  ? Border.all(color: const Color(0xFF2F2F4A), width: 1.0)
                  : null,
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? RiriTheme.offWhite : Colors.white,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
