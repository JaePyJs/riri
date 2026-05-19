import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai/ai_models.dart';
import '../../core/persistence/riri_repository.dart';
import '../../core/persistence/riri_providers.dart';
import '../../theme/riri_theme.dart';
import '../reminders/add_reminder_sheet.dart';
import 'riri_asset_mapper.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _mascotController;
  late final Animation<Offset> _mascotAnimation;

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
  }

  @override
  void dispose() {
    _mascotController.dispose();
    super.dispose();
  }

  /// Pure computation helper to determine Riri's interactive character state.
  static DashboardState determineCharacterState(List<RiriReminder> tasks) {
    final active = tasks.where((t) => !t.isCompleted).toList();
    if (tasks.isEmpty) return DashboardState.empty;
    if (active.isEmpty) return DashboardState.success;

    final now = DateTime.now();
    final overdueCount = active.where((t) => t.dueDateTime.isBefore(now)).length;

    if (overdueCount > 0) return DashboardState.overdue;

    final workingCount = active.where((t) => t.dueDateTime.difference(now).inHours <= 4).length;
    if (workingCount > 0) return DashboardState.working;

    return DashboardState.ready;
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
    // Trigger medium haptic feedback!
    HapticFeedback.mediumImpact();

    final wasCompleted = reminder.isCompleted;
    await repository.toggleReminderCompletion(reminder.id);

    if (!wasCompleted) {
      if (mounted) {
        _showConfettiCelebration(context);
      }
    }
  }

  void _showConfettiCelebration(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Confetti',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
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
                  border: Border.all(color: RiriTheme.hotPink.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: RiriTheme.hotPink.withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/stickers/Confetti_Explosion.png',
                      width: 140,
                      height: 140,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.celebration, size: 80, color: RiriTheme.hotPink);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'OMG Bestie! 🎉',
                      style: TextStyle(
                        color: RiriTheme.hotPink,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Natapos mo rin! Ang galing mo naman, proud na proud si Riri sa\'yo! 💅✨ No more procrastinating!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RiriTheme.primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text('Salamat, Bestie! 💖', style: TextStyle(fontWeight: FontWeight.bold)),
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

    final charState = determineCharacterState(reminders);

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
                  colors: [RiriTheme.primaryPurple.withOpacity(0.2), Colors.transparent],
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
                        'Hi, $username! 👋',
                        style: theme.textTheme.displayMedium,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'G na tayo today! ✨',
                        style: TextStyle(
                          color: RiriTheme.secondaryAmber,
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
                              color: Colors.black.withOpacity(0.2),
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
                      const SizedBox(height: 16),
                      _buildProductivityCard(theme, reminders),
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
                        _buildProductivityCard(theme, reminders),
                        const SizedBox(height: 16),
                        Text(
                          'Your Tasks',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: reminders.isEmpty
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
                                          color: Colors.redAccent.withOpacity(0.8),
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
        ],
      ),
    );
  }

  Widget _buildProductivityCard(ThemeData theme, List<RiriReminder> tasks) {
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;

    // Calculate procrastination index
    double totalSnoozes = 0;
    for (final t in tasks) {
      totalSnoozes += (t.snoozeCount + t.rescheduleCount);
    }
    final double avgSnooze = totalCount == 0 ? 0.0 : totalSnoozes / totalCount;

    String label = 'Proactive 👑';
    Color color = RiriTheme.successGreen;
    if (avgSnooze > 0 && avgSnooze <= 1.0) {
      label = 'Mild Slacker ☕';
      color = RiriTheme.secondaryAmber;
    } else if (avgSnooze > 1.0 && avgSnooze <= 2.5) {
      label = 'Active Snoozer ⏰';
      color = Colors.orangeAccent;
    } else if (avgSnooze > 2.5) {
      label = 'Danger Slacker 💀';
      color = RiriTheme.dangerRed;
    }

    final int streak = totalCount == 0 ? 0 : (completedCount > 0 ? (completedCount * 1.5).ceil() : 0);

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
              const Text('Streak 🔥', style: TextStyle(color: RiriTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('$streak Days', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(width: 1, height: 24, color: const Color(0xFF2F2F4A)),
          // Completed
          Column(
            children: [
              const Text('Completed 💅', style: TextStyle(color: RiriTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('$completedCount/$totalCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(width: 1, height: 24, color: const Color(0xFF2F2F4A)),
          // Procrastination Index
          Column(
            children: [
              const Text('Procrastination Meter 🧠', style: TextStyle(color: RiriTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final RiriReminder reminder;
  final VoidCallback onToggle;

  const _ReminderCard({
    Key? key,
    required this.reminder,
    required this.onToggle,
  }) : super(key: key);

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

    final timeStr = '${reminder.dueDateTime.hour.toString().padLeft(2, '0')}:${reminder.dueDateTime.minute.toString().padLeft(2, '0')}';
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
                              color: reminder.isCompleted
                                  ? RiriTheme.successGreen
                                  : RiriTheme.textMuted,
                              width: 2.0,
                            ),
                            color: reminder.isCompleted
                                ? RiriTheme.successGreen.withOpacity(0.2)
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
                                decoration:
                                    reminder.isCompleted ? TextDecoration.lineThrough : null,
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
                                    color: RiriTheme.primaryPurple.withOpacity(0.15),
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
