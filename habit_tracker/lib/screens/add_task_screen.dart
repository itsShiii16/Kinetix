import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();

  final TaskService _taskService = TaskService();

  String _selectedCategory = 'Lifestyle';
  bool _isPriority = false;

  List<String> _repeatDays = [];
  bool _remindersEnabled = false;
  List<String> _reminders = [];

  final List<String> _categories = [
    'Lifestyle',
    'School',
    'Work',
    'Home'
  ];

  final List<String> _days = ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'];

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

    final task = TaskModel(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      category: _selectedCategory,
      type: 'simple',
      isDone: false,
      isPriority: _isPriority,
      repeatDays: _repeatDays,
      remindersEnabled: _remindersEnabled,
      reminders: _reminders,
      icon: Icons.task_alt,
      color: Colors.white,
    );

    await _taskService.createTask(task);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('New Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Task Name"),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Enter task"),
            ),

            const SizedBox(height: 20),

            const Text("Description"),
            const SizedBox(height: 8),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(hintText: "Optional"),
            ),

            const SizedBox(height: 20),

            const Text("Category"),
            Wrap(
              spacing: 10,
              children: _categories.map((c) {
                return _chip(
                  c,
                  _selectedCategory == c,
                  () => setState(() => _selectedCategory = c),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            const Text("Repeat"),
            Wrap(
              spacing: 8,
              children: _days.map((d) {
                return _chip(
                  d,
                  _repeatDays.contains(d),
                  () => _toggleDay(d),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Text("Reminders"),
                Switch(
                  value: _remindersEnabled,
                  onChanged: (val) {
                    setState(() => _remindersEnabled = val);
                  },
                )
              ],
            ),

            if (_remindersEnabled) ...[
              Wrap(
                spacing: 10,
                children: _reminders
                    .map((r) => Chip(label: Text(r)))
                    .toList(),
              ),
              TextButton(
                onPressed: _addReminder,
                child: const Text("+ Add Reminder"),
              )
            ],

            const SizedBox(height: 20),

            Row(
              children: [
                const Text("Priority"),
                Switch(
                  value: _isPriority,
                  onChanged: (val) {
                    setState(() => _isPriority = val);
                  },
                )
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _saveTask,
              child: const Text("Save Task"),
            )
          ],
        ),
      ),
    );
  }
}