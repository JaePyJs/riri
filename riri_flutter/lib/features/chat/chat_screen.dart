import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/ai/ai_models.dart';
import '../../core/ai/chat_response_engine.dart';
import '../../core/ai/gemini_service.dart';
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
  
  late final http.Client _httpClient;
  late final GeminiService _geminiService;
  
  bool _isTyping = false;
  bool _isSending = false;
  bool _showVoiceOverlay = false;
  int _lastAnimatedCount = 0; // Messages at or below this index skip entrance animation
  String _localActiveThreadId = '';

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _geminiService = GeminiService(client: _httpClient);
    _loadPersonalityAndHistory();
  }

  @override
  void dispose() {
    _httpClient.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonalityAndHistory() async {
    final repo = ref.read(repositoryProvider);
    setState(() {
      _lastAnimatedCount = repo.chatHistory.length;
    });

    if (repo.chatHistory.isEmpty) {
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
        ? config.copy.greetingWithName.replaceAll('{name}', username)
        : config.copy.greetingWithoutName;

    repo.addChatMessage(
      text: greeting,
      isUser: false,
      stickerName: currentMode == PersonalityMode.malupit ? 'Angry' : 'Welcoming',
    );
  }

  void _sendMessage() {
    if (_isSending) return;
    
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final repo = ref.read(repositoryProvider);

    setState(() {
      _isSending = true;
      _isTyping = true;
    });

    repo.addChatMessage(
      text: text,
      isUser: true,
    );

    _scrollToBottom();

    // Trigger async AI logic
    Future.microtask(() async {
      try {
        final currentMode = ref.read(personalityModeProvider);
        final username = ref.read(usernameProvider);
        final apiKey = ref.read(geminiApiKeyProvider);
        
        // Learn user name dynamically from the conversation!
        final newlyExtractedName = _responseEngine.tryExtractName(text);
        if (newlyExtractedName != null && newlyExtractedName.isNotEmpty) {
          await ref.read(usernameProvider.notifier).setUsername(newlyExtractedName);
        }

        String responseText = '';
        String stickerName = 'Welcoming';

        final messages = ref.read(chatHistoryStreamProvider).value ?? [];

        // 1. Attempt Gemini response first if API key is active
        if (apiKey.trim().isNotEmpty) {
          try {
            // Convert RiriChatMessage list to a simple serializable format for history context
            final historyList = messages.map((m) => {
              'text': m.text,
              'isUser': m.isUser,
            }).toList();

            final geminiResult = await _geminiService.generateResponse(
              apiKey: apiKey,
              userInput: text,
              personalityMode: currentMode,
              userName: newlyExtractedName ?? username,
              history: historyList,
            );

            if (geminiResult != null) {
              final String? parsedText = geminiResult['text'];
              final String? parsedSticker = geminiResult['sticker'];
              final Map<String, dynamic>? parsedTask = geminiResult['taskCard'];

              if (parsedText != null && parsedText.isNotEmpty) {
                responseText = parsedText;
                stickerName = parsedSticker ?? 'Welcoming';

                // If a task card is detected, append the [TASK_CARD] structured prefix and raw JSON!
                if (parsedTask != null && parsedTask.isNotEmpty) {
                  final taskJson = jsonEncode(parsedTask);
                  responseText = '$responseText\n\n[TASK_CARD]$taskJson';
                }
              }
            }
          } catch (_) {
            // Fall back gracefully below
          }
        }

        // 2. Fall back to local synchronous ChatResponseEngine heuristics if Gemini was skipped or failed
        if (responseText.isEmpty) {
          final response = _responseEngine.generateResponse(
            userInput: text,
            personalityMode: currentMode,
            newlyLearnedName: newlyExtractedName,
          );
          responseText = response.text;
          stickerName = response.stickerName;
        }

        // 3. Save Riri chat response message cleanly in repository
        await repo.addChatMessage(
          text: responseText,
          isUser: false,
          stickerName: stickerName,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isTyping = false;
            _isSending = false;
          });
          _scrollToBottom();
        }
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
  }

  void _startVoiceSimulation() {
    setState(() {
      _showVoiceOverlay = true;
    });
  }

  void _onSpeechCompleted(String transcription) {
    setState(() {
      _showVoiceOverlay = false;
    });
    _messageController.text = transcription;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final chatAsync = ref.watch(chatHistoryStreamProvider);
    final messages = chatAsync.value ?? [];
    final theme = Theme.of(context);
    final personalityMode = ref.watch(personalityModeProvider);
    
    // Sync active thread ID and reset anim counts
    final activeThreadId = repo.activeThreadId;
    if (_localActiveThreadId != activeThreadId) {
      _localActiveThreadId = activeThreadId;
      _lastAnimatedCount = messages.length;
    }

    ref.listen<AsyncValue<List<RiriChatMessage>>>(chatHistoryStreamProvider, (previous, next) {
      final list = next.value ?? [];
      
      // Update animation count on initial load
      if (previous == null || !previous.hasValue) {
        setState(() {
          _lastAnimatedCount = list.length;
        });
      }
      
      // Greeting if thread is empty
      if (next.hasValue && list.isEmpty) {
        _sendRiriGreeting();
      }
    });

    return Scaffold(
      backgroundColor: RiriTheme.darkBg,
      drawer: _ChatHistoryDrawer(
        onThreadSelected: () {
          final activeMsgs = repo.chatHistory;
          setState(() {
            _lastAnimatedCount = activeMsgs.length;
          });
          if (activeMsgs.isEmpty) {
            _sendRiriGreeting();
          }
        },
      ),
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
                  itemCount: messages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final msg = messages[index];
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
                          onStateChanged: () {},
                        ),
                      );
                    }
                    return _ChatBubble(
                      message: msg,
                      onStateChanged: () {},
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
                    GestureDetector(
                      onTap: _startVoiceSimulation,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: RiriTheme.primaryPurple.withValues(alpha: 0.15),
                          border: Border.all(
                            color: RiriTheme.primaryPurple.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: RiriTheme.hotPink,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
          if (_showVoiceOverlay)
            _VoiceSimulationOverlay(
              onClose: () {
                setState(() {
                  _showVoiceOverlay = false;
                });
              },
              onSpeechCompleted: _onSpeechCompleted,
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
                          ? config.copy.savedGreeting
                          : config.copy.cancelledGreeting),
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
                                config.copy.saveButtonLabel,
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
                                config.copy.cancelButtonLabel,
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
                                config.copy.savedBannerText,
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
                                config.copy.cancelledBannerText,
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

class _ChatHistoryDrawer extends ConsumerWidget {
  final VoidCallback onThreadSelected;

  const _ChatHistoryDrawer({required this.onThreadSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);

    return Drawer(
      backgroundColor: RiriTheme.darkBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conversations 📜',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Swapping your nagging topics...',
                    style: TextStyle(
                      fontSize: 12,
                      color: RiriTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFF2F2F4A), height: 1),

            // + New Thread Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: RiriTheme.brandGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final newId = DateTime.now().millisecondsSinceEpoch.toString();
                    await repo.createNewThread(
                      id: newId,
                      title: 'New Thread',
                    );
                    onThreadSelected();
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text(
                    'New Conversation',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),

            // Scrollable list of threads
            Expanded(
              child: StreamBuilder<List<RiriChatThread>>(
                stream: repo.threadsStream,
                initialData: repo.threads,
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        'Walang conversations... 😭',
                        style: TextStyle(color: RiriTheme.textMuted),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final thread = list[index];
                      final isActive = thread.id == repo.activeThreadId;

                      return Container(
                        decoration: BoxDecoration(
                          color: isActive ? RiriTheme.primaryPurple.withValues(alpha: 0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: isActive
                              ? Border.all(color: RiriTheme.primaryPurple.withValues(alpha: 0.4), width: 1.0)
                              : Border.all(color: Colors.transparent, width: 1.0),
                        ),
                        child: ListTile(
                          onTap: () async {
                            await repo.switchActiveThread(thread.id);
                            onThreadSelected();
                          },
                          leading: Icon(
                            isActive ? Icons.chat_bubble : Icons.chat_bubble_outline,
                            color: isActive ? RiriTheme.primaryPurple : RiriTheme.textSecondary,
                            size: 20,
                          ),
                          title: Text(
                            thread.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isActive ? Colors.white : RiriTheme.offWhite,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Don't show delete on the only default thread
                              if (list.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: RiriTheme.textMuted, size: 18),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: RiriTheme.cardBg,
                                        title: const Text('Delete Thread? 💔'),
                                        content: Text('Sigurado ka bang burahin ang "${thread.title}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Wag muna', style: TextStyle(color: RiriTheme.textMuted)),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await repo.deleteThread(thread.id);
                                              onThreadSelected();
                                            },
                                            child: const Text('Burahin', style: TextStyle(color: RiriTheme.dangerRed)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceSimulationOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<String> onSpeechCompleted;

  const _VoiceSimulationOverlay({
    required this.onClose,
    required this.onSpeechCompleted,
  });

  @override
  State<_VoiceSimulationOverlay> createState() => _VoiceSimulationOverlayState();
}

class _VoiceSimulationOverlayState extends State<_VoiceSimulationOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  Timer? _typingTimer;
  String _targetText = '';
  String _typedText = '';
  int _charIndex = 0;
  bool _isSuccess = false;

  final List<String> _taglishPrompts = [
    "Riri, paki-nag naman ako mamaya na gumawa ng assignments... Sobrang tinatamad ako eh!",
    "Musta Riri! Paki-remind naman ako na uminom ng tubig at mag-stretching. Salamat!",
    "Riri, super pagod ako today. Pwede bang mag-log ng personal task para magpahinga at manood ng series?"
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _targetText = _taglishPrompts[Random().nextInt(_taglishPrompts.length)];

    Timer(const Duration(milliseconds: 800), _startTypingSimulation);
  }

  void _startTypingSimulation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) return;
      if (_charIndex < _targetText.length) {
        setState(() {
          _charIndex++;
          _typedText = _targetText.substring(0, _charIndex);
        });
      } else {
        _typingTimer?.cancel();
        setState(() {
          _isSuccess = true;
        });
        Timer(const Duration(milliseconds: 1000), () {
          if (mounted) {
            widget.onSpeechCompleted(_targetText);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.6),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Title
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        _isSuccess ? 'Success! 🎉' : 'Listening... 🎙️',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSuccess ? 'Sending transcript to Riri...' : 'Say something in English or Taglish',
                        style: const TextStyle(
                          fontSize: 13,
                          color: RiriTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Center Waveform Visualizer
                  Column(
                    children: [
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(double.infinity, 120),
                            painter: SinusoidalWavePainter(
                              animationValue: _waveController.value,
                              amplitude: _isSuccess ? 0.0 : 35.0,
                              color: _isSuccess ? RiriTheme.successGreen : RiriTheme.primaryPurple,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (_isSuccess ? RiriTheme.successGreen : RiriTheme.primaryPurple).withValues(alpha: 0.2),
                          border: Border.all(
                            color: (_isSuccess ? RiriTheme.successGreen : RiriTheme.primaryPurple).withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isSuccess ? RiriTheme.successGreen : RiriTheme.primaryPurple).withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isSuccess ? Icons.check : Icons.mic,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Speech to Text Simulation Box
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2F).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2F2F4A),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TRANSCRIBED VOICE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: RiriTheme.textSecondary,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 60,
                              child: SingleChildScrollView(
                                child: Text(
                                  '$_typedText${_isSuccess ? "" : "_"}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: widget.onClose,
                        style: TextButton.styleFrom(
                          foregroundColor: RiriTheme.textMuted,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SinusoidalWavePainter extends CustomPainter {
  final double animationValue;
  final double amplitude;
  final Color color;

  SinusoidalWavePainter({
    required this.animationValue,
    this.amplitude = 30.0,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final yCenter = size.height / 2;

    for (double x = 0; x <= size.width; x++) {
      final y = yCenter + amplitude * sin((x / size.width * 2 * pi * 2.5) - (animationValue * 2 * pi));
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    final path2 = Path();
    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (double x = 0; x <= size.width; x++) {
      final y = yCenter + (amplitude * 0.6) * sin((x / size.width * 2 * pi * 3.0) + (animationValue * 2 * pi));
      if (x == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    canvas.drawPath(path2, paint2);

    final path3 = Path();
    final paint3 = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (double x = 0; x <= size.width; x++) {
      final y = yCenter + (amplitude * 0.4) * sin((x / size.width * 2 * pi * 1.5) - (animationValue * pi));
      if (x == 0) {
        path3.moveTo(x, y);
      } else {
        path3.lineTo(x, y);
      }
    }
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant SinusoidalWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.color != color;
  }
}
