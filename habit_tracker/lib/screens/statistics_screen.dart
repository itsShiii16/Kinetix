import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';
import '../widgets/shared/app_bottom_nav_bar.dart';

enum StatisticsView { weekly, monthly, yearly }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatisticsView _selectedView = StatisticsView.weekly;
  late DateTime _focusedDate;

  final TaskService _taskService = TaskService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> _categoryOrder = const [
    'Lifestyle',
    'School',
    'Work',
    'Home',
  ];

  final Map<String, Color> _categoryColors = const {
    'Lifestyle': Color(0xFF56CCF2),
    'School': Color(0xFFB4A6FF),
    'Work': Color(0xFFFF9A62),
    'Home': Color(0xFF7EE6A2),
  };

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
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

  List<String> _getColumnLabels(List<List<DateTime>> slots) {
    switch (_selectedView) {
      case StatisticsView.weekly:
        return ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'];
      case StatisticsView.monthly:
        return List.generate(slots.length, (index) => 'W${index + 1}');
      case StatisticsView.yearly:
        return ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    }
  }

  List<List<DateTime>> _getSlots() {
    switch (_selectedView) {
      case StatisticsView.weekly:
        final start = _startOfWeek(_focusedDate);
        return List.generate(
          7,
          (index) => [_dateOnly(start.add(Duration(days: index)))],
        );

      case StatisticsView.monthly:
        final firstDay = DateTime(_focusedDate.year, _focusedDate.month, 1);
        final lastDay = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);

        final slots = <List<DateTime>>[];
        DateTime cursor = firstDay;
        List<DateTime> currentWeek = [];

        while (!cursor.isAfter(lastDay)) {
          currentWeek.add(_dateOnly(cursor));

          if (cursor.weekday == DateTime.sunday) {
            slots.add(List.from(currentWeek));
            currentWeek.clear();
          }

          cursor = cursor.add(const Duration(days: 1));
        }

        if (currentWeek.isNotEmpty) {
          slots.add(List.from(currentWeek));
        }

        return slots;

      case StatisticsView.yearly:
        return List.generate(12, (index) {
          final firstDay = DateTime(_focusedDate.year, index + 1, 1);
          final lastDay = DateTime(_focusedDate.year, index + 2, 0);

          final dates = <DateTime>[];
          DateTime cursor = firstDay;
          while (!cursor.isAfter(lastDay)) {
            dates.add(_dateOnly(cursor));
            cursor = cursor.add(const Duration(days: 1));
          }
          return dates;
        });
    }
  }

  bool _taskScheduledOnDate(TaskModel task, DateTime date) {
    if (task.isDeleted) return false;

    final normalizedDate = _dateOnly(date);
    final startDate = _parseStorageDate(task.startDate);
    final endDate = _parseStorageDate(task.endDate);

    if (startDate != null && normalizedDate.isBefore(_dateOnly(startDate))) {
      return false;
    }

    if (endDate != null && normalizedDate.isAfter(_dateOnly(endDate))) {
      return false;
    }

    if (task.repeatDays.isEmpty) {
      return true;
    }

    return task.repeatDays.contains(_weekdayLabel(normalizedDate));
  }

  Map<String, dynamic> _buildDisplayData(
    List<TaskModel> allTasks,
    Map<String, bool> logMap,
  ) {
    final slots = _getSlots();
    final labels = _getColumnLabels(slots);

    final activeTasks = allTasks.where((task) => !task.isDeleted).toList();
    final rows = <String, List<bool>>{};
    final categoryInstanceSummary = <String, Map<String, int>>{};

    int totalScheduledInstances = 0;
    int totalCompletedInstances = 0;

    final categoriesToShow = _categoryOrder
        .where((category) => activeTasks.any((task) => task.category == category))
        .toList();

    for (final category in categoriesToShow) {
      final categoryTasks =
          activeTasks.where((task) => task.category == category).toList();

      final categoryRow = <bool>[];
      int categoryScheduled = 0;
      int categoryCompleted = 0;

      for (final slotDates in slots) {
        int slotScheduled = 0;
        int slotCompleted = 0;

        for (final date in slotDates) {
          final dateKey = _dateKey(date);

          for (final task in categoryTasks) {
            if (_taskScheduledOnDate(task, date)) {
              slotScheduled++;
              if (logMap['$dateKey|${task.id}'] == true) {
                slotCompleted++;
              }
            }
          }
        }

        totalScheduledInstances += slotScheduled;
        totalCompletedInstances += slotCompleted;
        categoryScheduled += slotScheduled;
        categoryCompleted += slotCompleted;

        categoryRow.add(slotScheduled > 0 && slotCompleted == slotScheduled);
      }

      rows[category] = categoryRow;
      categoryInstanceSummary[category] = {
        'scheduled': categoryScheduled,
        'completed': categoryCompleted,
      };
    }

    return {
      'labels': labels,
      'rows': rows,
      'totalScheduledInstances': totalScheduledInstances,
      'totalCompletedInstances': totalCompletedInstances,
      'categoryInstanceSummary': categoryInstanceSummary,
      'groupCount': rows.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
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
                      'Failed to load logs.',
                      style: GoogleFonts.nunitoSans(color: Colors.white),
                    ),
                  );
                }

                final logMap = _buildLogMap(logSnapshot.data!);
                final displayData = _buildDisplayData(tasks, logMap);
                final labels = displayData['labels'] as List<String>;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildViewTabs(),
                      const SizedBox(height: 24),
                      _buildRangeSelector(),
                      const SizedBox(height: 24),
                      _buildSummaryCards(displayData),
                      const SizedBox(height: 24),
                      _buildGroupGrid(labels, displayData),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildViewTabs() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _buildTabButton('Weekly', StatisticsView.weekly),
          _buildTabButton('Monthly', StatisticsView.monthly),
          _buildTabButton('Yearly', StatisticsView.yearly),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, StatisticsView view) {
    final isActive = _selectedView == view;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedView = view;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isActive ? Colors.white : AppColors.mutedText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildArrowButton(
          icon: Icons.arrow_back_ios_rounded,
          onTap: _goToPreviousRange,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            _formatRangeLabel(),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        _buildArrowButton(
          icon: Icons.arrow_forward_ios_rounded,
          onTap: _goToNextRange,
        ),
      ],
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: AppColors.secondary,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> displayData) {
    final int totalCompletions =
        displayData['totalCompletedInstances'] as int;
    final int totalSlots =
        displayData['totalScheduledInstances'] as int;
    final double rate = totalSlots == 0 ? 0 : totalCompletions / totalSlots;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Completion Rate',
            value: '${(rate * 100).round()}%',
            subtitle: 'Real DB activity',
            accent: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Groups Tracked',
            value: '${displayData['groupCount']}',
            subtitle: 'From Firestore tasks',
            accent: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupGrid(
    List<String> labels,
    Map<String, dynamic> displayData,
  ) {
    final Map<String, List<bool>> rows =
        displayData['rows'] as Map<String, List<bool>>;
    final Map<String, Map<String, int>> categorySummary =
        (displayData['categoryInstanceSummary'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, Map<String, int>.from(value)),
    );

    final categories = rows.keys.toList();

    if (categories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          'No tracked task groups yet.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.mutedText,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 140),
              ...labels.map(
                (label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...categories.map((category) {
            final completions =
                rows[category] ?? List.filled(labels.length, false);
            final accent = _categoryColors[category] ?? AppColors.primary;
            final scheduled = categorySummary[category]?['scheduled'] ?? 0;
            final completed = categorySummary[category]?['completed'] ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completed / $scheduled',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...completions.map(
                    (isDone) => Expanded(
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDone
                                ? accent.withOpacity(0.12)
                                : AppColors.muted.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDone ? accent : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _goToPreviousRange() {
    setState(() {
      switch (_selectedView) {
        case StatisticsView.weekly:
          _focusedDate = _focusedDate.subtract(const Duration(days: 7));
          break;
        case StatisticsView.monthly:
          _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
          break;
        case StatisticsView.yearly:
          _focusedDate = DateTime(_focusedDate.year - 1, 1, 1);
          break;
      }
    });
  }

  void _goToNextRange() {
    setState(() {
      switch (_selectedView) {
        case StatisticsView.weekly:
          _focusedDate = _focusedDate.add(const Duration(days: 7));
          break;
        case StatisticsView.monthly:
          _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
          break;
        case StatisticsView.yearly:
          _focusedDate = DateTime(_focusedDate.year + 1, 1, 1);
          break;
      }
    });
  }

  String _formatRangeLabel() {
    switch (_selectedView) {
      case StatisticsView.weekly:
        final start = _startOfWeek(_focusedDate);
        final end = start.add(const Duration(days: 6));
        return '${_twoDigits(start.day)}/${_twoDigits(start.month)} - ${_twoDigits(end.day)}/${_twoDigits(end.month)}';
      case StatisticsView.monthly:
        return '${_monthName(_focusedDate.month)} ${_focusedDate.year}';
      case StatisticsView.yearly:
        return '${_focusedDate.year}';
    }
  }

  DateTime _startOfWeek(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: diff));
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _monthName(int month) {
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
    return months[month - 1];
  }
}