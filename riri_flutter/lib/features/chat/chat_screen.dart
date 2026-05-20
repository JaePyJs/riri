import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai/ai_models.dart';
import '../../core/ai/chat_response_engine.dart';
import '../../core/persistence/riri_repository.dart';
import '../../core/persistence/riri_providers.dart';
import '../../core/notifications/personality_copy.dart';
import '../../core/notifications/personas.dart';
import '../../theme/riri_theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

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

    final config = PersonaConfig.get(currentMode);
    final greeting = hasName
        ? config.greetingWithName.replaceAll('{name}', username)
        : config.greetingWithoutName;

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

      // 2. Save Riri chat response message cleanly in repository (which may contain [TASK_CARD] JSON)
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
                  style: TextStyle(
                    color: PersonaConfig.get(personalityMode).accentColor,
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
                    final repo = ref.read(repositoryProvider);
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
                        child: _ChatBubble(
                          message: msg,
                          onStateChanged: () {
                            setState(() {
                              _messages = repo.chatHistory;
                            });
                          },
                        ),
                      );
                    }
                    return _ChatBubble(
                      message: msg,
                      onStateChanged: () {
                        setState(() {
                          _messages = repo.chatHistory;
                        });
                      },
                    );
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

class _ChatBubble extends ConsumerWidget {
  final RiriChatMessage message;
  final VoidCallback? onStateChanged;

  const _ChatBubble({required this.message, this.onStateChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTaskCard = !message.isUser && message.text.startsWith('[TASK_CARD]');
    final personalityMode = ref.watch(personalityModeProvider);

    if (isTaskCard) {
      try {
        final jsonStr = message.text.substring('[TASK_CARD]'.length);
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        final title = data['title'] as String;
        final categoryStr = data['category'] as String;
        final dueDateStr = data['dueDate'] as String;
        final stateStr = data['state'] as String;

        final category = ReminderCategory.values.firstWhere(
          (e) => e.name == categoryStr,
          orElse: () => ReminderCategory.personal,
        );
        final dueDateTime = DateTime.parse(dueDateStr);

        return _buildTaskCardBubble(
          context: context,
          ref: ref,
          personalityMode: personalityMode,
          messageId: message.id,
          title: title,
          category: category,
          dueDateTime: dueDateTime,
          state: stateStr,
        );
      } catch (e) {
        return _buildNormalBubble(context, 'Maling format ng paalala card... 🥺');
      }
    }

    return _buildNormalBubble(context, message.text);
  }

  Widget _buildNormalBubble(BuildContext context, String text) {
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
                'assets/stickers/${message.stickerName}.webp',
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
              text,
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

  Widget _buildTaskCardBubble({
    required BuildContext context,
    required WidgetRef ref,
    required PersonalityMode personalityMode,
    required int messageId,
    required String title,
    required ReminderCategory category,
    required DateTime dueDateTime,
    required String state,
  }) {
    final config = PersonaConfig.get(personalityMode);
    final greetingText = config.standard.renderBody({'task': title});

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
                'assets/stickers/${message.stickerName}.webp',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: RiriTheme.brandGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  state == 'pending'
                      ? greetingText
                      : (state == 'saved'
                          ? config.savedGreeting
                          : config.cancelledGreeting),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2F).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: state == 'saved'
                        ? RiriTheme.successGreen.withValues(alpha: 0.6)
                        : (state == 'cancelled'
                            ? RiriTheme.textMuted.withValues(alpha: 0.3)
                            : config.accentColor.withValues(alpha: 0.5)),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (state == 'saved'
                          ? RiriTheme.successGreen
                          : (state == 'cancelled'
                              ? Colors.transparent
                              : config.accentColor)).withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryChip(category),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: RiriTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          _formatDueDateTime(dueDateTime),
                          style: const TextStyle(
                            color: RiriTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (state == 'pending') ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: config.accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                final repo = ref.read(repositoryProvider);
                                await repo.addReminder(
                                  title: title,
                                  category: category,
                                  dueDateTime: dueDateTime,
                                );
                                final jsonStr = json.encode({
                                  'title': title,
                                  'category': category.name,
                                  'dueDate': dueDateTime.toIso8601String(),
                                  'state': 'saved',
                                });
                                await repo.updateChatMessageText(messageId, '[TASK_CARD]$jsonStr');
                                onStateChanged?.call();
                              },
                              child: Text(
                                config.saveButtonLabel,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF2C2C3E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Color(0xFF3F3F5C)),
                              ),
                              padding: const EdgeInsets.all(8),
                            ),
                            icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                            onPressed: () {
                              _showEditDialog(
                                context,
                                ref,
                                messageId,
                                title,
                                category,
                                dueDateTime,
                                onStateChanged,
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: RiriTheme.textMuted,
                                side: const BorderSide(color: Color(0xFF3F3F5C)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                final repo = ref.read(repositoryProvider);
                                final jsonStr = json.encode({
                                  'title': title,
                                  'category': category.name,
                                  'dueDate': dueDateTime.toIso8601String(),
                                  'state': 'cancelled',
                                });
                                await repo.updateChatMessageText(messageId, '[TASK_CARD]$jsonStr');
                                onStateChanged?.call();
                              },
                              child: Text(
                                config.cancelButtonLabel,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (state == 'saved') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: RiriTheme.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: RiriTheme.successGreen.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: RiriTheme.successGreen, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                config.savedBannerText,
                                style: const TextStyle(
                                  color: RiriTheme.successGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (state == 'cancelled') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cancel, color: RiriTheme.textMuted, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                config.cancelledBannerText,
                                style: const TextStyle(
                                  color: RiriTheme.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(ReminderCategory category) {
    Color chipColor;
    switch (category) {
      case ReminderCategory.school:
        chipColor = Colors.blue;
        break;
      case ReminderCategory.work:
        chipColor = Colors.orange;
        break;
      case ReminderCategory.health:
        chipColor = RiriTheme.successGreen;
        break;
      case ReminderCategory.social:
        chipColor = RiriTheme.primaryPurple;
        break;
      case ReminderCategory.errands:
        chipColor = Colors.teal;
        break;
      case ReminderCategory.personal:
        chipColor = RiriTheme.secondaryAmber;
        break;
      case ReminderCategory.bahalaNa:
        chipColor = RiriTheme.dangerRed;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        category.taglishLabel,
        style: TextStyle(
          color: chipColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDueDateTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final isTomorrow = dt.year == now.year && dt.month == now.month && dt.day == now.add(const Duration(days: 1)).day;
    
    final timeStr = "${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    
    if (isToday) {
      return "Today, $timeStr";
    } else if (isTomorrow) {
      return "Tomorrow, $timeStr";
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${months[dt.month - 1]} ${dt.day}, $timeStr";
    }
  }



  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    int messageId,
    String initialTitle,
    ReminderCategory initialCategory,
    DateTime initialDueDate,
    VoidCallback? onStateChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return _EditCardDialog(
          messageId: messageId,
          initialTitle: initialTitle,
          initialCategory: initialCategory,
          initialDueDate: initialDueDate,
          onStateChanged: onStateChanged,
        );
      },
    );
  }
}

class _EditCardDialog extends ConsumerStatefulWidget {
  final int messageId;
  final String initialTitle;
  final ReminderCategory initialCategory;
  final DateTime initialDueDate;
  final VoidCallback? onStateChanged;

  const _EditCardDialog({
    required this.messageId,
    required this.initialTitle,
    required this.initialCategory,
    required this.initialDueDate,
    this.onStateChanged,
  });

  @override
  ConsumerState<_EditCardDialog> createState() => _EditCardDialogState();
}

class _EditCardDialogState extends ConsumerState<_EditCardDialog> {
  late final TextEditingController _titleController;
  late ReminderCategory _selectedCategory;
  late DateTime _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _selectedCategory = widget.initialCategory;
    _selectedDueDate = widget.initialDueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatDueDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final timeStr = "${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    return "${months[dt.month - 1]} ${dt.day}, ${dt.year} at $timeStr";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: RiriTheme.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2F2F4A), width: 1.5),
          ),
          title: Row(
            children: const [
              Icon(Icons.edit_note, color: RiriTheme.primaryPurple, size: 28),
              SizedBox(width: 8),
              Text(
                'Ayusin ang Paalala',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ANO ANG GAGAWIN?',
                  style: TextStyle(color: RiriTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: RiriTheme.darkBg,
                    hintText: 'e.g. Uminom ng tubig',
                    hintStyle: const TextStyle(color: RiriTheme.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF2F2F4A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: RiriTheme.primaryPurple),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'KATEGORYA',
                  style: TextStyle(color: RiriTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ReminderCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(
                        cat.taglishLabel,
                        style: TextStyle(
                          color: isSelected ? Colors.white : RiriTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: RiriTheme.primaryPurple,
                      backgroundColor: RiriTheme.darkBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? RiriTheme.primaryPurple : const Color(0xFF2F2F4A),
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'KAILAN DAPAT GAWIN?',
                  style: TextStyle(color: RiriTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDueDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: RiriTheme.primaryPurple,
                              onPrimary: Colors.white,
                              surface: RiriTheme.cardBg,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      if (!context.mounted) return;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDueDate),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: RiriTheme.primaryPurple,
                                onPrimary: Colors.white,
                                surface: RiriTheme.cardBg,
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        setState(() {
                          _selectedDueDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: RiriTheme.darkBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF2F2F4A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: RiriTheme.primaryPurple, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _formatDueDate(_selectedDueDate),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: RiriTheme.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('I-cancel', style: TextStyle(color: RiriTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: RiriTheme.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final newTitle = _titleController.text.trim();
                if (newTitle.isEmpty) return;

                final repo = ref.read(repositoryProvider);
                final jsonStr = json.encode({
                  'title': newTitle,
                  'category': _selectedCategory.name,
                  'dueDate': _selectedDueDate.toIso8601String(),
                  'state': 'pending',
                });
                await repo.updateChatMessageText(widget.messageId, '[TASK_CARD]$jsonStr');
                widget.onStateChanged?.call();
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('I-save Changes'),
            ),
          ],
        );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

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

        // Apply sine-wave active bounce and resting phase for organic bubble physics
        final curved = progress < 0.5 ? sin(pi * (progress / 0.5)) : 0.0;
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
