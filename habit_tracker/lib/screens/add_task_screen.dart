import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';
import '../widgets/shared/animated_scale_button.dart';

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

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  final List<String> _categories = [
    'Lifestyle',
    'School',
    'Work',
    'Home'
  ];

  final List<String> _days = ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'];

  void _toggleDay(String day) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_repeatDays.contains(day)) {
        _repeatDays.remove(day);
      } else {
        _repeatDays.add(day);
      }
    });
  }

  Future<void> _pickStartDate() async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;

        // ensure end date is not before start
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    HapticFeedback.lightImpact();
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

  Future<void> _addReminder() async {
    HapticFeedback.lightImpact();
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

    HapticFeedback.mediumImpact();

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
      startDate: _toStorageDate(_startDate),
      endDate: _endDate != null ? _toStorageDate(_endDate!) : null,
      icon: Icons.task_alt,
      color: Colors.white,
    );

    await _taskService.createTask(task);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
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
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }
  
  String _toStorageDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}


  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'add_task_fab',
      createRectTween: (begin, end) {
        return MaterialRectCenterArcTween(begin: begin, end: end);
      },
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        final Hero toHero = toHeroContext.widget as Hero;
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return ClipOval(
              clipper: _CircleClipper(animation.value),
              child: toHero.child,
            );
          },
        );
      },
      child: Scaffold(
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

              const Text("Start Date"),
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _pickStartDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Ink(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(_formatDate(_startDate)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text("End Date (Optional)"),
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _pickEndDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Ink(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _endDate == null
                          ? "No end date"
                          : _formatDate(_endDate!),
                    ),
                  ),
                ),
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

              AnimatedScaleButton(
                onTap: _saveTask,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Save Task"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleClipper extends CustomClipper<Rect> {
  final double fraction;

  _CircleClipper(this.fraction);

  @override
  Rect getClip(Size size) {
    final double maxRadius = size.longestSide * 1.5;
    final double currentRadius = maxRadius * fraction;
    
    // Position center at the initial FAB location relative to the destination screen
    // For simplicity, we center it, but in a real radial Hero, 
    // it usually expands from the source's rect center.
    return Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2), 
      radius: currentRadius,
    );
  }

  @override
  bool shouldReclip(_CircleClipper oldClipper) =>
      oldClipper.fraction != fraction;
}