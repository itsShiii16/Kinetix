import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/task_model.dart';
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

  final List<TaskModel> _tasks = [
    TaskModel(
      id: '1',
      title: 'Drink Water',
      subtitle: 'Health goal',
      category: 'Lifestyle',
      type: 'progress',
      current: 6,
      total: 8,
      isDone: false,
      isPriority: true,
      icon: Icons.water_drop_rounded,
      color: const Color(0xFF56CCF2),
    ),
    TaskModel(
      id: '2',
      title: 'Walk',
      subtitle: '45 mins',
      category: 'Lifestyle',
      type: 'simple',
      isDone: true,
      isPriority: true,
      icon: Icons.directions_walk_rounded,
      color: const Color(0xFFFFC857),
    ),
    TaskModel(
      id: '3',
      title: 'Complete Reading',
      subtitle: 'Personal growth',
      category: 'School',
      type: 'simple',
      isDone: true,
      isPriority: true,
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF4CD97B),
    ),
    TaskModel(
      id: '4',
      title: 'Stop Tea at Night',
      subtitle: 'Habit control',
      category: 'Lifestyle',
      type: 'simple',
      isDone: false,
      isPriority: false,
      icon: Icons.emoji_food_beverage_rounded,
      color: const Color(0xFFFF9A62),
    ),
    TaskModel(
      id: '5',
      title: 'Prepare for Work',
      subtitle: 'Morning setup',
      category: 'Work',
      type: 'simple',
      isDone: false,
      isPriority: false,
      icon: Icons.work_outline_rounded,
      color: const Color(0xFFFF6B6B),
    ),
    TaskModel(
      id: '6',
      title: 'Sleep before 11',
      subtitle: 'Recovery',
      category: 'Lifestyle',
      type: 'simple',
      isDone: false,
      isPriority: false,
      icon: Icons.nightlight_round,
      color: const Color(0xFF8E7CFF),
    ),
    TaskModel(
      id: '7',
      title: 'Reply Emails',
      subtitle: 'Inbox cleanup',
      category: 'Work',
      type: 'simple',
      isDone: true,
      isPriority: false,
      icon: Icons.email_rounded,
      color: const Color(0xFFFF9A62),
    ),
    TaskModel(
      id: '8',
      title: 'Prepare Dinner',
      subtitle: 'Before 7PM',
      category: 'Home',
      type: 'simple',
      isDone: false,
      isPriority: false,
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFFF8F5A),
    ),
  ];

  late Map<String, List<bool>> _categoryCompletionMap;

  final Map<String, Color> _categoryColors = {
    'Lifestyle': const Color(0xFF56CCF2),
    'School': const Color(0xFF4CD97B),
    'Work': const Color(0xFFFF9A62),
    'Home': const Color(0xFF8E7CFF),
  };

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();

    _categoryCompletionMap = {
      'Lifestyle': [false, true, true, false, true, false, false],
      'School': [false, false, true, true, true, false, false],
      'Work': [false, false, false, true, true, false, false],
      'Home': [false, false, false, false, true, false, false],
    };
  }

  @override
  Widget build(BuildContext context) {
    final labels = _getColumnLabels();
    final displayData = _getDisplayData();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
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
    final int totalCompletions = displayData['totalCompletions'] as int;
    final int totalSlots = displayData['totalSlots'] as int;
    final double rate = totalSlots == 0 ? 0 : totalCompletions / totalSlots;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Completion Rate',
            value: '${(rate * 100).round()}%',
            subtitle: 'Across all groups',
            accent: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Groups Tracked',
            value: '${displayData['rows'].length}',
            subtitle: 'Lifestyle, School, Work, Home',
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
    final categories = rows.keys.toList();

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
              const SizedBox(width: 110),
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

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Row(
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

  Map<String, dynamic> _getDisplayData() {
    int slotCount;

    switch (_selectedView) {
      case StatisticsView.weekly:
        slotCount = 7;
        break;
      case StatisticsView.monthly:
        slotCount = 4;
        break;
      case StatisticsView.yearly:
        slotCount = 12;
        break;
    }

    final Map<String, List<bool>> rows = {};

    for (final entry in _categoryCompletionMap.entries) {
      final original = entry.value;
      final generated = List.generate(
        slotCount,
        (index) => index < original.length ? original[index] : false,
      );
      rows[entry.key] = generated;
    }

    int totalCompletions = 0;
    for (final values in rows.values) {
      totalCompletions += values.where((v) => v).length;
    }

    return {
      'rows': rows,
      'totalCompletions': totalCompletions,
      'totalSlots': rows.length * slotCount,
    };
  }

  List<String> _getColumnLabels() {
    switch (_selectedView) {
      case StatisticsView.weekly:
        return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      case StatisticsView.monthly:
        return ['W1', 'W2', 'W3', 'W4'];
      case StatisticsView.yearly:
        return ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    }
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
        return _monthName(_focusedDate.month);
      case StatisticsView.yearly:
        return '${_focusedDate.year}';
    }
  }

  DateTime _startOfWeek(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: diff));
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