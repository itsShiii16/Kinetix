import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TaskService _taskService = TaskService();

  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;

  late String _selectedCategory;
  late bool _isPriority;
  late List<String> _repeatDays;
  late bool _remindersEnabled;
  late List<String> _reminders;

  final List<String> _categories = [
    'Lifestyle',
    'School',
    'Work',
    'Home',
  ];

  final List<String> _days = ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _subtitleController = TextEditingController(text: widget.task.subtitle);
    _selectedCategory = widget.task.category;
    _isPriority = widget.task.isPriority;
    _repeatDays = List<String>.from(widget.task.repeatDays);
    _remindersEnabled = widget.task.remindersEnabled;
    _reminders = List<String>.from(widget.task.reminders);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _toggleDay(String day) {
    setState(() {
      if (_repeatDays.contains(day)) {
        _repeatDays.remove(day);
      } else {
        _repeatDays.add(day);
      }
    });
  }

  Future<void> _addReminder() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final formatted =
          "${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";

      setState(() {
        _reminders.add(formatted);
      });
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) return;

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      category: _selectedCategory,
      isPriority: _isPriority,
      repeatDays: _repeatDays,
      remindersEnabled: _remindersEnabled,
      reminders: _reminders,
    );

    await _taskService.updateTask(updatedTask);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _softDeleteTask() async {
    await _taskService.softDeleteTask(widget.task.id);

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task moved to Recently Deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _taskService.restoreTask(widget.task.id);
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Move task to Recently Deleted?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'You can restore it later from Archive.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.bg,
                    ),
                    child: const Text('Move to Archive'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.mutedText),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete == true) {
      await _softDeleteTask();
    }
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.muted,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.bg : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.mutedText,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.mutedText.withOpacity(0.7)),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: Colors.white,
        title: const Text('Edit Task'),
        actions: [
          IconButton(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('TASK NAME'),
            _inputField(
              controller: _titleController,
              hintText: 'Enter task name',
            ),
            const SizedBox(height: 18),
            _sectionTitle('DESCRIPTION'),
            _inputField(
              controller: _subtitleController,
              hintText: 'Optional description',
            ),
            const SizedBox(height: 18),
            _sectionTitle('GROUP'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((category) {
                return _chip(
                  category,
                  _selectedCategory == category,
                  () => setState(() => _selectedCategory = category),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _sectionTitle('REPEAT ON'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _days.map((day) {
                return _chip(
                  day,
                  _repeatDays.contains(day),
                  () => _toggleDay(day),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Priority',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Switch(
                  value: _isPriority,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _isPriority = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Reminders',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Switch(
                  value: _remindersEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _remindersEnabled = value);
                  },
                ),
              ],
            ),
            if (_remindersEnabled) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _reminders.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reminder = entry.value;

                  return Chip(
                    label: Text(reminder),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _reminders.removeAt(index);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _addReminder,
                child: const Text('+ Add Reminder'),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.bg,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}