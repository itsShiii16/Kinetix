import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';
import '../widgets/shared/app_bottom_nav_bar.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TaskService _taskService = TaskService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _logsStream() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('task_logs')
        .snapshots();
  }

  String _dateKey(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  String _weekdayLabel(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'M';
      case DateTime.tuesday:
        return 'T';
      case DateTime.wednesday:
        return 'W';
      case DateTime.thursday:
        return 'Th';
      case DateTime.friday:
        return 'F';
      case DateTime.saturday:
        return 'Sa';
      case DateTime.sunday:
        return 'Su';
      default:
        return '';
    }
  }

  DateTime? _parseStorageDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    try {
      final parts = value.split('-');
      if (parts.length != 3) return null;

      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return null;
    }
  }

  bool _isTaskScheduledForDate(TaskModel task, DateTime date) {
    final normalizedDate = _dateOnly(date);
    final startDate = _parseStorageDate(task.startDate);
    final endDate = _parseStorageDate(task.endDate);

    if (startDate != null &&
        normalizedDate.isBefore(_dateOnly(startDate))) {
      return false;
    }

    if (endDate != null &&
        normalizedDate.isAfter(_dateOnly(endDate))) {
      return false;
    }

    if (task.repeatDays.isEmpty) {
      return true;
    }

    return task.repeatDays.contains(_weekdayLabel(normalizedDate));
  }

  List<DateTime?> _getCalendarDaysForMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    final cells = <DateTime?>[];

    for (int i = 0; i < startWeekday; i++) {
      cells.add(null);
    }

    for (int day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(month.year, month.month, day));
    }

    while (cells.length < 42) {
      cells.add(null);
    }

    return cells;
  }

  Map<String, bool> _buildLogMap(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final map = <String, bool>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final taskId = data['taskId']?.toString();
      final date = data['date']?.toString();
      final isCompleted = data['isCompleted'] == true;

      if (taskId != null && date != null) {
        map['$date|$taskId'] = isCompleted;
      }
    }

    return map;
  }

  List<TaskModel> _tasksForDate(List<TaskModel> tasks, DateTime date) {
    return tasks.where((task) {
      if (task.isDeleted) return false;
      return _isTaskScheduledForDate(task, date);
    }).toList();
  }

  bool _isDayFullyCompleted(
    DateTime date,
    List<TaskModel> allTasks,
    Map<String, bool> logMap,
  ) {
    final dayTasks = _tasksForDate(allTasks, date);
    if (dayTasks.isEmpty) return false;

    final dateKey = _dateKey(date);
    return dayTasks.every((task) => logMap['$dateKey|${task.id}'] == true);
  }

  Set<DateTime> _getVisibleStreakDaysForMonth(
    DateTime month,
    List<TaskModel> tasks,
    Map<String, bool> logMap,
  ) {
    final result = <DateTime>{};

    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    int streakCount = 0;
    final currentRun = <DateTime>[];

    DateTime cursor = firstDay;
    while (!cursor.isAfter(lastDay)) {
      final normalized = _dateOnly(cursor);

      if (_isDayFullyCompleted(normalized, tasks, logMap)) {
        streakCount++;
        currentRun.add(normalized);
      } else {
        if (streakCount >= 3) {
          result.addAll(currentRun);
        }
        streakCount = 0;
        currentRun.clear();
      }

      cursor = cursor.add(const Duration(days: 1));
    }

    if (streakCount >= 3) {
      result.addAll(currentRun);
    }

    return result;
  }

  int _getCurrentStreak(List<TaskModel> tasks, Map<String, bool> logMap) {
    int streak = 0;
    DateTime cursor = _dateOnly(DateTime.now());

    while (_isDayFullyCompleted(cursor, tasks, logMap)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<void> _toggleTaskForSelectedDate(TaskModel task) async {
    final selectedKey = _dateKey(_selectedDate);
    final isToday = _isSameDate(_selectedDate, DateTime.now());

    if (isToday) {
      await _taskService.toggleTaskCompletion(task);
      return;
    }

    final logQuery = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('task_logs')
        .where('taskId', isEqualTo: task.id)
        .where('date', isEqualTo: selectedKey)
        .get();

    if (logQuery.docs.isNotEmpty) {
      final doc = logQuery.docs.first;
      final current = doc.data()['isCompleted'] == true;

      await doc.reference.update({
        'isCompleted': !current,
      });
    } else {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('task_logs')
          .add({
        'taskId': task.id,
        'category': task.category,
        'date': selectedKey,
        'isCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatSelectedActivityDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthDates = _getCalendarDaysForMonth(_focusedMonth);

    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBody: true,
      body: SafeArea(
        child: StreamBuilder<List<TaskModel>>(
          stream: _taskService.getActiveTasks(),
          builder: (context, taskSnapshot) {
            if (taskSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (taskSnapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load tasks.',
                  style: GoogleFonts.nunitoSans(color: Colors.white),
                ),
              );
            }

            final tasks = taskSnapshot.data ?? [];

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _logsStream(),
              builder: (context, logSnapshot) {
                if (logSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (logSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load task logs.',
                      style: GoogleFonts.nunitoSans(color: Colors.white),
                    ),
                  );
                }

                final logMap = _buildLogMap(logSnapshot.data!);
                final monthStreakDays =
                    _getVisibleStreakDaysForMonth(_focusedMonth, tasks, logMap);
                final currentStreak = _getCurrentStreak(tasks, logMap);

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(currentStreak),
                      _buildMonthSelector(),
                      _buildCalendarGrid(
                        currentMonthDates,
                        monthStreakDays,
                        tasks,
                        logMap,
                      ),
                      _buildActivitySection(tasks, logMap),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHeader(int currentStreak) {
    final streakText = currentStreak >= 3
        ? '$currentStreak day streak! 🔥'
        : 'Build a 3-day streak to light it up.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your History',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                streakText,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          Hero(
            tag: 'add_task_fab',
            createRectTween: (begin, end) {
              return MaterialRectCenterArcTween(begin: begin, end: end);
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTaskScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(Icons.add_rounded, color: AppColors.bg, size: 32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.mutedText,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                  1,
                );

                if (!_isSameMonth(_selectedDate, _focusedMonth)) {
                  _selectedDate = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month,
                    1,
                  );
                }
              });
            },
          ),
          Text(
            _formatMonthYear(_focusedMonth),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.mutedText,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                  1,
                );

                if (!_isSameMonth(_selectedDate, _focusedMonth)) {
                  _selectedDate = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month,
                    1,
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    List<DateTime?> monthCells,
    Set<DateTime> streakDays,
    List<TaskModel> tasks,
    Map<String, bool> logMap,
  ) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.muted.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map(
                  (day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.mutedText,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          ...List.generate(6, (rowIndex) {
            final rowItems = monthCells.skip(rowIndex * 7).take(7).toList();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: rowItems.map((date) {
                  if (date == null) {
                    return const Expanded(child: SizedBox(height: 48));
                  }

                  final normalizedDate = _dateOnly(date);
                  final isSelected = _isSameDate(normalizedDate, _selectedDate);
                  final isToday = _isSameDate(normalizedDate, DateTime.now());
                  final isCompletedDay =
                      _isDayFullyCompleted(normalizedDate, tasks, logMap);
                  final isPartOfValidStreak = streakDays.contains(normalizedDate);

                  Color textColor = AppColors.mutedText;
                  FontWeight fontWeight = FontWeight.bold;

                  if (isPartOfValidStreak) {
                    textColor = AppColors.primary;
                    fontWeight = FontWeight.w900;
                  } else if (isCompletedDay) {
                    textColor = Colors.white;
                    fontWeight = FontWeight.w800;
                  }

                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedDate = normalizedDate;
                          });
                        },
                        borderRadius: BorderRadius.circular(17),
                        child: Container(
                          height: 48,
                          color: Colors.transparent,
                          child: Center(
                            child: isSelected
                                ? Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primary.withOpacity(0.3),
                                        width: 4,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${normalizedDate.day}',
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.bg,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 34,
                                    height: 34,
                                    decoration: isToday
                                        ? BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.secondary
                                                  .withOpacity(0.6),
                                            ),
                                          )
                                        : null,
                                    child: Center(
                                      child: Text(
                                        '${normalizedDate.day}',
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 16,
                                          fontWeight: fontWeight,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivitySection(
    List<TaskModel> allTasks,
    Map<String, bool> logMap,
  ) {
    final selectedTasks = _tasksForDate(allTasks, _selectedDate);
    final selectedKey = _dateKey(_selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasks for ${_formatSelectedActivityDate(_selectedDate)}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (selectedTasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No tasks scheduled for this day.',
                  style: GoogleFonts.nunitoSans(
                    color: AppColors.mutedText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ...selectedTasks.map((task) {
            final isCompleted = logMap['$selectedKey|${task.id}'] == true;
            final timeText = task.remindersEnabled && task.reminders.isNotEmpty
                ? 'Reminder: ${task.reminders.join(', ')}'
                : 'No reminder';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildActivityCard(
                task: task,
                time: timeText,
                isCompleted: isCompleted,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required TaskModel task,
    required String time,
    required bool isCompleted,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditTaskScreen(task: task),
            ),
          );
        },
        onLongPress: () async {
          await _toggleTaskForSelectedDate(task);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(isCompleted ? 1.0 : 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.muted.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: task.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${task.category} • $time',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: isCompleted ? AppColors.primary : AppColors.mutedText,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}