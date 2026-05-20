import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai/chat_response_engine.dart';
import '../../core/persistence/riri_repository.dart';
import '../../core/persistence/riri_providers.dart';
import '../../core/notifications/personality_copy.dart';
import '../../core/notifications/personas.dart';
import '../../theme/riri_theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatResponseEngine _responseEngine = ChatResponseEngine();
  List<RiriChatMessage> _messages = [];
  bool _isTyping = false;
  int _lastAnimatedCount = 0; // Messages at or below this index skip entrance animation

  @override
  void initState() {
    super.initState();
    _loadPersonalityAndHistory();
  }

  Future<void> _loadPersonalityAndHistory() async {
    final repo = ref.read(repositoryProvider);
    setState(() {
      _messages = repo.chatHistory;
      _lastAnimatedCount = _messages.length; // History loads without animation
    });

    if (_messages.isEmpty) {
      _sendRiriGreeting();
    }
  }

  void _sendRiriGreeting() {
    final repo = ref.read(repositoryProvider);
    final currentMode = ref.read(personalityModeProvider);
    final username = ref.read(usernameProvider);
    final hasName = username.trim().isNotEmpty;

    String greeting;
    switch (currentMode) {
      case PersonalityMode.bestie:
        greeting = hasName 
            ? 'Hoy, $username! Riri here, ready to achieve our goals with you! Ano na plano natin today? ✨'
            : 'Uy, musta na? Riri here, ready to achieve our goals with you! Ano na plano natin today? ✨';
        break;
      case PersonalityMode.malupit:
        greeting = hasName
            ? 'Riri here, $username. Ready to do some work or are you planning to snooze all day? Speak up.'
            : 'Riri here. Ready to do some work or are you planning to snooze all day? Speak up.';
        break;
      case PersonalityMode.chill:
        greeting = hasName
            ? 'Hey, $username~ Riri here. Relax ka lang, everything is under control. Ano gagawin natin today? 🍃'
            : 'Hey~ Uy, musta na? Riri here. Relax ka lang, everything is under control. Ano gagawin natin today? 🍃';
        break;
      case PersonalityMode.tita:
        greeting = hasName
            ? 'Kumain ka na ba, $username anak? Riri dito. Halika, ilista natin ang kailangan mong gawin ha? 👵'
            : 'Kumain ka na ba anak? Riri dito. Halika, ilista natin ang kailangan mong gawin ha? 👵';
        break;
    }

    repo.addChatMessage(
      text: greeting,
      isUser: false,
      stickerName: currentMode == PersonalityMode.malupit ? 'Angry' : 'Welcoming',
    );

    setState(() {
      _messages = repo.chatHistory;
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final repo = ref.read(repositoryProvider);

    repo.addChatMessage(
      text: text,
      isUser: true,
    );

    setState(() {
      _messages = repo.chatHistory;
      _isTyping = true;
    });

    _scrollToBottom();

    Timer(const Duration(milliseconds: 1000), () async {
      final currentMode = ref.read(personalityModeProvider);
      
      // Learn user name dynamically from the conversation!
      final newlyExtractedName = _responseEngine.tryExtractName(text);
      if (newlyExtractedName != null && newlyExtractedName.isNotEmpty) {
        await ref.read(usernameProvider.notifier).setUsername(newlyExtractedName);
      }

      // 1. Generate standard persona response using ChatResponseEngine
      final response = _responseEngine.generateResponse(
        userInput: text,
        personalityMode: currentMode,
        newlyLearnedName: newlyExtractedName,
      );

      // 2. Perform task creation if intent is detected
      if (response.extractedTitle != null &&
          response.extractedCategory != null &&
          response.extractedDueDate != null) {
        await repo.addReminder(
          title: response.extractedTitle!,
          category: response.extractedCategory!,
          dueDateTime: response.extractedDueDate!,
        );
      }

      // 3. Save Riri chat response message cleanly in repository
      await repo.addChatMessage(
        text: response.text,
        isUser: false,
        stickerName: response.stickerName,
      );

      if (mounted) {
        setState(() {
          _messages = repo.chatHistory;
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
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
    final repo = ref.read(repositoryProvider);
    await repo.clearChatHistory();
    setState(() {
      _messages = [];
    });
    _sendRiriGreeting();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final personalityMode = ref.watch(personalityModeProvider);

    return Scaffold(
      backgroundColor: RiriTheme.darkBg,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: RiriTheme.primaryPurple.withValues(alpha: 0.2),
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
                  '${PersonaConfig.get(personalityMode).name} Mode Active 💅',
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
                  content: const Text('Gusto mo ba burahin yung memories natin? 🥺'),
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
                  colors: [RiriTheme.primaryPurple.withValues(alpha: 0.12), Colors.transparent],
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
                    // Only animate messages that arrived after initial history load
                    if (index >= _lastAnimatedCount) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 14),
                            child: child,
                          ),
                        ),
                        child: _ChatBubble(message: msg),
                      );
                    }
                    return _ChatBubble(message: msg);
                  },
                ),
              ),

              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Row(
                    children: const [
                      _TypingIndicator(),
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
                            hintText: 'Chika ka lang dito...',
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
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: child,
              ),
              child: Image.asset(
                'assets/stickers/${message.stickerName}.png',
                width: 44,
                height: 44,
                errorBuilder: (context, error, stackTrace) {
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: RiriTheme.primaryPurple.withValues(alpha: 0.2),
                    child: const Icon(Icons.face, color: RiriTheme.primaryPurple, size: 20),
                  );
                },
              ),
            ),
          ] else ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: RiriTheme.primaryPurple.withValues(alpha: 0.2),
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

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({Key? key}) : super(key: key);

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double delay = index * 0.25;
        // Shift the animation phase per dot, wrap around [0, 1]
        double progress = (_controller.value - delay) % 1.0;
        if (progress < 0) progress += 1.0;

        // Apply easeInOut curve on the [0, 1] phase for organic bounce feel
        final curved = Curves.easeInOut.transform(
          progress < 0.5 ? progress * 2.0 : 1.0 - (progress - 0.5) * 2.0,
        );
        final double offset = -curved * 7.0;

        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: RiriTheme.textSecondary,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Riri is typing',
          style: TextStyle(
            color: RiriTheme.textSecondary,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 6),
        _buildDot(0),
        _buildDot(1),
        _buildDot(2),
      ],
    );
  }
}
