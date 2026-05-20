import 'package:flutter/material.dart';
import '../../core/ai/ai_models.dart';
import '../../theme/riri_theme.dart';

class AddReminderSheet extends StatefulWidget {
  final Function({
    required String title,
    String? description,
    required ReminderCategory category,
    required DateTime dueDateTime,
  }) onSave;

  const AddReminderSheet({Key? key, required this.onSave}) : super(key: key);

  @override
  _AddReminderSheetState createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  ReminderCategory _selectedCategory = ReminderCategory.personal;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTitleEmpty = _titleController.text.trim().isEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: RiriTheme.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle indicator
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: RiriTheme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Add New Reminder 🗓️',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Title input - utilizes global InputDecorationTheme
            TextField(
              controller: _titleController,
              onChanged: (val) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Ano ang gagawin natin? (Title)',
                prefixIcon: Icon(Icons.title, color: RiriTheme.textMuted),
              ),
            ),
            const SizedBox(height: 12),

            // Description input - utilizes global InputDecorationTheme
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Any extra chika or details? (Description - Optional)',
                prefixIcon: Icon(Icons.description, color: RiriTheme.textMuted),
              ),
            ),
            const SizedBox(height: 20),

            // Category Picker Title
            Text(
              'Select Category',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Category selector horizontal scroll row
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ReminderCategory.values.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = ReminderCategory.values[index];
                  final isSelected = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? RiriTheme.primaryPurple 
                            : RiriTheme.darkBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? RiriTheme.primaryPurple 
                              : const Color(0xFF2F2F4A),
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat.taglishLabel,
                        style: TextStyle(
                          color: isSelected ? Colors.white : RiriTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Date & Time Picker Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Due Date & Time',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _selectDateTime,
                  icon: const Icon(Icons.calendar_month, size: 16),
                  label: Text(
                    '${_selectedDate.month}/${_selectedDate.day} at ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RiriTheme.darkBg,
                    foregroundColor: RiriTheme.secondaryAmber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF2F2F4A)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isTitleEmpty
                    ? null
                    : () {
                        widget.onSave(
                          title: _titleController.text.trim(),
                          description: _descController.text.trim().isNotEmpty
                              ? _descController.text.trim()
                              : null,
                          category: _selectedCategory,
                          dueDateTime: _selectedDate,
                        );
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: RiriTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: RiriTheme.darkBg,
                  disabledForegroundColor: RiriTheme.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 6,
                  shadowColor: RiriTheme.primaryPurple.withValues(alpha: 0.3),
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: isTitleEmpty ? null : RiriTheme.brandGradient,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Add Task na! 🚀',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
