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

  late DateTime _startDate;
  DateTime? _endDate;

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

    // 🔥 PARSE STRING → DATETIME
    _startDate = _parseDate(widget.task.startDate) ?? DateTime.now();
    _endDate = _parseDate(widget.task.endDate);
  }

  DateTime? _parseDate(String? date) {
    if (date == null) return null;
    try {
      final parts = date.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return null;
    }
  }

  String _toStorageDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;

        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
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

  Future<void> _saveTask() async {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      category: _selectedCategory,
      isPriority: _isPriority,
      repeatDays: _repeatDays,
      remindersEnabled: _remindersEnabled,
      reminders: _reminders,
      startDate: _toStorageDate(_startDate),
      endDate: _endDate != null ? _toStorageDate(_endDate!) : null,
    );

    await _taskService.updateTask(updatedTask);

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
        title: const Text('Edit Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Task Name"),
            TextField(controller: _titleController),

            const SizedBox(height: 16),

            const Text("Description"),
            TextField(controller: _subtitleController),

            const SizedBox(height: 16),

            const Text("Start Date"),
            GestureDetector(
              onTap: _pickStartDate,
              child: Text(_formatDate(_startDate)),
            ),

            const SizedBox(height: 16),

            const Text("End Date"),
            GestureDetector(
              onTap: _pickEndDate,
              child: Text(
                _endDate == null ? "No end date" : _formatDate(_endDate!),
              ),
            ),

            const SizedBox(height: 16),

            const Text("Repeat"),
            Wrap(
              children: _days.map((d) {
                return _chip(
                  d,
                  _repeatDays.contains(d),
                  () => _toggleDay(d),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveTask,
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}