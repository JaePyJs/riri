import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../core/ai/ai_models.dart';
import '../../core/notifications/personas.dart';
import '../../core/notifications/personality_copy.dart';
import '../../core/persistence/riri_repository.dart';
import '../../core/persistence/riri_providers.dart';
import '../../theme/riri_theme.dart';
import '../reminders/add_reminder_sheet.dart';
import 'riri_asset_mapper.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with TickerProviderStateMixin {
  late final AnimationController _mascotController;
  late final Animation<Offset> _mascotAnimation;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _mascotController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _mascotAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.05),
    ).animate(CurvedAnimation(
      parent: _mascotController,
      curve: Curves.easeInOut,
    ));
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _mascotController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// Explicit static bottom sheet helper.
  static void _showAddReminderBottomSheet(BuildContext context, RiriRepository repository) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddReminderSheet(
          onSave: ({
            required String title,
            String? description,
            required ReminderCategory category,
            required DateTime dueDateTime,
          }) {
            repository.addReminder(
              title: title,
              description: description,
              category: category,
              dueDateTime: dueDateTime,
            );
          },
        );
      },
    );
  }

  void _triggerTaskCompletionPayoff(RiriReminder reminder, RiriRepository repository) async {
    HapticFeedback.mediumImpact();
    final wasCompleted = reminder.isCompleted;
    await repository.toggleReminderCompletion(reminder.id);
    if (!wasCompleted && mounted) {
      final mode = ref.read(personalityModeProvider);
      _confettiController.play();
      _showConfettiCelebration(context, mode);
    }
  }

  void _showConfettiCelebration(BuildContext context, PersonalityMode mode) {
    // Drive all copy from PersonaConfig — no hardcoded switch-case text
    final persona = PersonaConfig.get(mode);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Confetti',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogContext, anim1, anim2) {
        // Auto-dismiss after 2.5s so repeated completions don't force manual taps
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
        });
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: anim1,
                curve: Curves.elasticOut,
              ),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF252538),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: persona.accentColor.withValues(alpha: 0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: persona.accentColor.withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      persona.copy.completionEmoji,
                      style: const TextStyle(
                        fontSize: 84,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      persona.copy.completionHeadline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: persona.accentColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      persona.copy.completionBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: persona.accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          persona.copy.completionButtonLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watch providers directly to decouple callback prop-drilling
    final repository = ref.watch(repositoryProvider);
    final remindersAsync = ref.watch(remindersStreamProvider);
    final reminders = remindersAsync.value ?? repository.currentReminders;
    final username = ref.watch(usernameProvider);
    final isLoading = remindersAsync.isLoading && (remindersAsync.value == null || remindersAsync.value!.isEmpty);

    // Dynamic reactive state calculations from Riverpod providers
    final streak = ref.watch(streakProvider);
    final procrastination = ref.watch(procrastinationIndexProvider);
    final charState = ref.watch(characterStateProvider);
    final activePersona = PersonaConfig.get(ref.watch(personalityModeProvider));

    return Scaffold(
      backgroundColor: RiriTheme.darkBg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderBottomSheet(context, repository),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RiriTheme.brandGradient,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      body: Stack(
        children: [
          // Background elegant top glow gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [activePersona.accentColor.withValues(alpha: 0.2), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Elegant Header Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username.trim().isEmpty ? 'Hi! 👋' : 'Hi, $username! 👋',
                        style: theme.textTheme.displayMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Let's handle your tasks one step at a time.",
                        style: TextStyle(
                          color: activePersona.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Riri Dynamic Status Nudge Card
                      Container(
                        decoration: BoxDecoration(
                          color: RiriTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2F2F4A), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SlideTransition(
                              position: _mascotAnimation,
                              child: Image.asset(
                                RiriAssetMapper.getAssetPath(charState),
                                width: 68,
                                height: 68,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RiriTheme.brandGradient,
                                    ),
                                    child: const Icon(Icons.psychology, size: 32, color: Colors.white),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    RiriAssetMapper.getGenZCopy(charState),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'You have ${reminders.where((t) => !t.isCompleted).length} tasks left.',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Tasks List Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildProductivityCard(theme, reminders, streak, procrastination),
                        const SizedBox(height: 16),
                        Text(
                          'Your Tasks',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: isLoading
                              ? ListView.separated(
                                  itemCount: 3,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) => _buildSkeletonCard(),
                                )
                              : reminders.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Clean as a whistle! 💅\nWala kang pending tasks.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: RiriTheme.textMuted,
                                          fontSize: 16,
                                          height: 1.4,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                  itemCount: reminders.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final reminder = reminders[index];
                                    return Dismissible(
                                      key: Key('reminder_${reminder.id}'),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(right: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(Icons.delete, color: Colors.white),
                                      ),
                                      onDismissed: (direction) {
                                        HapticFeedback.mediumImpact();
                                        repository.deleteReminder(reminder.id);
                                      },
                                      child: _ReminderCard(
                                        reminder: reminder,
                                        onToggle: () => _triggerTaskCompletionPayoff(reminder, repository),
                                      ),
                                    ).animate().fade(duration: 400.ms, delay: (index * 60).ms).slideY(
                                          begin: 0.15,
                                          end: 0.0,
                                          curve: Curves.easeOutQuad,
                                        );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Option A Screen-Wide Confetti Particle Layer (top stack layer)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: activePersona.confettiColors,
              numberOfParticles: 28,
              maxBlastForce: 25,
              minBlastForce: 8,
              gravity: 0.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityCard(
    ThemeData theme,
    List<RiriReminder> tasks,
    int streak,
    ProcrastinationIndexData procrastination,
  ) {
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2F2F4A), width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Streak
          Column(
            children: [
              const Text(
                'Streak 🔥',
                style: TextStyle(color: RiriTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '$streak Days',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(width: 1, height: 24, color: const Color(0xFF2F2F4A)),
          // Completed
          Column(
            children: [
              const Text(
                'Completed 💅',
                style: TextStyle(color: RiriTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '$completedCount/$totalCount',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(width: 1, height: 24, color: const Color(0xFF2F2F4A)),
          // Procrastination Index
          Column(
            children: [
              const Text(
                'Procrastination 🧠',
                style: TextStyle(color: RiriTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                procrastination.label,
                style: TextStyle(color: procrastination.color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: RiriTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2F2F4A), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            color: const Color(0xFF2F2F4A),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2F2F4A),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F2F4A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F2F4A),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 80,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F2F4A),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .fade(begin: 0.3, end: 0.6, duration: 800.ms);
  }
}

class _ReminderCard extends StatelessWidget {
  final RiriReminder reminder;
  final VoidCallback onToggle;

  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isOverdue = !reminder.isCompleted && reminder.dueDateTime.isBefore(now);

    final Color statusColor;
    if (reminder.isCompleted) {
      statusColor = RiriTheme.successGreen;
    } else if (isOverdue) {
      statusColor = RiriTheme.dangerRed;
    } else {
      statusColor = RiriTheme.primaryPurple;
    }

    final timeStr =
        '${reminder.dueDateTime.hour.toString().padLeft(2, '0')}:${reminder.dueDateTime.minute.toString().padLeft(2, '0')}';
    final dateStr = '${reminder.dueDateTime.month}/${reminder.dueDateTime.day}';

    return Container(
      decoration: BoxDecoration(
        color: RiriTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2F2F4A), width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                color: statusColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onToggle,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: reminder.isCompleted ? RiriTheme.successGreen : RiriTheme.textMuted,
                              width: 2.0,
                            ),
                            color: reminder.isCompleted
                                ? RiriTheme.successGreen.withValues(alpha: 0.2)
                                : Colors.transparent,
                          ),
                          child: reminder.isCompleted
                              ? const Icon(Icons.check, size: 14, color: RiriTheme.successGreen)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              reminder.title,
                              style: TextStyle(
                                color: reminder.isCompleted ? RiriTheme.textMuted : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                reminder.description!,
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: RiriTheme.primaryPurple.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    reminder.category.taglishLabel,
                                    style: const TextStyle(
                                      color: RiriTheme.primaryPurple,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: isOverdue ? RiriTheme.dangerRed : RiriTheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$timeStr ($dateStr)',
                                  style: TextStyle(
                                    color: isOverdue ? RiriTheme.dangerRed : RiriTheme.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
