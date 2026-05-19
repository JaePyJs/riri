import 'package:flutter/material.dart';
import '../../core/ai/ai_models.dart';
import '../../core/persistence/riri_repository.dart';
import '../../theme/riri_theme.dart';
import 'riri_asset_mapper.dart';

class DashboardScreen extends StatelessWidget {
  final String username;
  final List<RiriReminder> reminders;
  final Function(int) onToggleCompletion;
  final Function(int) onDeleteReminder;
  final VoidCallback onAddReminderTap;

  const DashboardScreen({
    Key? key,
    required this.username,
    required this.reminders,
    required this.onToggleCompletion,
    required this.onDeleteReminder,
    required this.onAddReminderTap,
  }) : super(key: key);

  DashboardState _determineCharacterState(List<RiriReminder> tasks) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final charState = _determineCharacterState(reminders);
    final activeReminders = reminders.where((t) => !t.isCompleted).toList();

    return Scaffold(
      backgroundColor: RiriTheme.darkBg,
      floatingActionButton: FloatingActionButton(
        onPressed: onAddReminderTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Header Area
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: RiriTheme.cardBg,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
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
                    color: RiriTheme.darkBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2F2F4A), width: 1.2),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Image.asset(
                        RiriAssetMapper.getAssetPath(charState),
                        width: 68,
                        height: 68,
                        errorBuilder: (context, error, stackTrace) {
                          // Icon fallback
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
                              'You have ${activeReminders.length} tasks left.',
                              style: const TextStyle(
                                color: RiriTheme.textSecondary,
                                fontSize: 12,
                              ),
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
                  const SizedBox(height: 24),
                  const Text(
                    'Your Tasks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                                onDismissed: (direction) => onDeleteReminder(reminder.id),
                                child: _ReminderCard(
                                  reminder: reminder,
                                  onToggle: () => onToggleCompletion(reminder.id),
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

    // Format relative/friendly due time
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
              // Left status vertical colored accent bar (matches compose LeftBorder)
              Container(
                width: 5,
                color: statusColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Checkbox completion toggle button
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

                      // Text Info
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
                                style: const TextStyle(
                                  color: RiriTheme.textSecondary,
                                  fontSize: 12,
                                ),
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
