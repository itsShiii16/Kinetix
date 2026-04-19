import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // --- THEME COLORS ---
  final Color bgColor = const Color(0xFF151515);
  final Color primaryColor = const Color(0xFFD4FF00);
  final Color secondaryColor = const Color(0xFFB4A6FF);
  final Color cardColor = const Color(0xFF2A2A2C);
  final Color mutedColor = const Color(0xFF3A3A3C);
  final Color mutedTextColor = const Color(0xFF8E8E93);
  final Color destructiveColor = const Color(0xFFFF453A);

  // --- CALENDAR STATE ---
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  // Dummy local DB keyed by full date.
  // Replace this later with Firestore data grouped by date.
  late final Map<DateTime, List<Map<String, dynamic>>> _activitiesByDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);

    _activitiesByDate = {
      DateTime(2026, 4, 20): [
        {
          'title': 'Daily Exercise',
          'time': 'Completed at 08:30 AM',
          'isCompleted': true,
          'color': const Color(0xFFD4FF00),
        },
        {
          'title': 'Reading Session',
          'time': 'Completed at 09:00 PM',
          'isCompleted': true,
          'color': const Color(0xFFB4A6FF),
        },
      ],
      DateTime(2026, 4, 21): [
        {
          'title': 'Drink 2L Water',
          'time': 'Completed at 07:10 PM',
          'isCompleted': true,
          'color': const Color(0xFFD4FF00),
        },
      ],
      DateTime(2026, 4, 22): [
        {
          'title': 'Read 30 Pages',
          'time': 'Completed at 09:00 PM',
          'isCompleted': true,
          'color': const Color(0xFFB4A6FF),
        },
        {
          'title': 'Meditation',
          'time': 'Completed at 06:40 AM',
          'isCompleted': true,
          'color': const Color(0xFFD4FF00),
        },
      ],
      DateTime(2026, 4, 23): [
        {
          'title': 'Read 30 Pages',
          'time': 'Completed at 09:00 PM',
          'isCompleted': true,
          'color': const Color(0xFFB4A6FF),
        },
      ],
      DateTime(2026, 4, 24): [
        {
          'title': 'Daily Exercise',
          'time': 'Completed at 08:30 AM',
          'isCompleted': true,
          'color': const Color(0xFFD4FF00),
        },
        {
          'title': 'Reading Session',
          'time': 'Skipped',
          'isCompleted': false,
          'color': const Color(0xFFB4A6FF),
        },
      ],
      DateTime(2026, 4, 25): [
        {
          'title': 'Drink 2L Water',
          'time': 'Pending',
          'isCompleted': false,
          'color': const Color(0xFFD4FF00),
        },
      ],
      DateTime(2026, 5, 1): [
        {
          'title': 'Workout',
          'time': 'Completed at 07:00 AM',
          'isCompleted': true,
          'color': const Color(0xFFD4FF00),
        },
      ],
      DateTime(2026, 5, 2): [
        {
          'title': 'Read 20 Pages',
          'time': 'Completed at 08:40 PM',
          'isCompleted': true,
          'color': const Color(0xFFB4A6FF),
        },
      ],
      DateTime(2026, 5, 3): [
        {
          'title': 'Stretching',
          'time': 'Completed at 06:30 AM',
          'isCompleted': true,
          'color': const Color(0xFFD4FF00),
        },
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthDates = _getCalendarDaysForMonth(_focusedMonth);
    final monthStreakDays = _getVisibleStreakDaysForMonth(_focusedMonth);
    final currentStreak = _getCurrentStreak();

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(currentStreak),
              _buildMonthSelector(),
              _buildCalendarGrid(currentMonthDates, monthStreakDays),
              _buildActivitySection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildInteractiveNavBar(),
    );
  }

  // --- HEADER ---

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
                  color: secondaryColor,
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Add new task for ${_formatLongDate(_selectedDate)}',
                    ),
                  ),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(Icons.add_rounded, color: bgColor, size: 32),
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
              color: mutedTextColor,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
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
              color: mutedTextColor,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
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

  // --- CALENDAR GRID ---

  Widget _buildCalendarGrid(
    List<DateTime?> monthCells,
    Set<DateTime> streakDays,
  ) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: mutedColor.withOpacity(0.5)),
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
                        color: mutedTextColor,
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
                    return const Expanded(
                      child: SizedBox(height: 48),
                    );
                  }

                  final normalizedDate = _dateOnly(date);
                  final isSelected = _isSameDate(normalizedDate, _selectedDate);
                  final isToday = _isSameDate(normalizedDate, DateTime.now());
                  final isCompletedDay = _isDayFullyCompleted(normalizedDate);
                  final isPartOfValidStreak = streakDays.contains(normalizedDate);

                  Color textColor = mutedTextColor;
                  FontWeight fontWeight = FontWeight.bold;

                  if (isPartOfValidStreak) {
                    textColor = primaryColor;
                    fontWeight = FontWeight.w900;
                  } else if (isCompletedDay) {
                    textColor = Colors.white;
                    fontWeight = FontWeight.w800;
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = normalizedDate;
                        });
                      },
                      child: Container(
                        height: 48,
                        color: Colors.transparent,
                        child: Center(
                          child: isSelected
                              ? Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.3),
                                      width: 4,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${normalizedDate.day}',
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: bgColor,
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
                                            color: secondaryColor
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
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- ACTIVITY SECTION ---

  Widget _buildActivitySection() {
    final todaysActivities = _activitiesByDate[_dateOnly(_selectedDate)] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity for ${_formatSelectedActivityDate(_selectedDate)}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (todaysActivities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No tasks scheduled for this day.',
                  style: GoogleFonts.nunitoSans(
                    color: mutedTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ...todaysActivities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildActivityCard(
                title: activity['title'] as String,
                time: activity['time'] as String,
                color: activity['color'] as Color,
                isCompleted: activity['isCompleted'] as bool,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String time,
    required Color color,
    required bool isCompleted,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Edit or Delete: $title')),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(isCompleted ? 1.0 : 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: mutedColor.withOpacity(0.5)),
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
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            time,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14,
                              color: mutedTextColor,
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
                    : Icons.cancel_rounded,
                color: isCompleted ? primaryColor : destructiveColor,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- STREAK LOGIC ---

  bool _isDayFullyCompleted(DateTime date) {
    final activities = _activitiesByDate[_dateOnly(date)];

    if (activities == null || activities.isEmpty) return false;

    return activities.every((activity) => activity['isCompleted'] == true);
  }

  Set<DateTime> _getVisibleStreakDaysForMonth(DateTime month) {
    final result = <DateTime>{};

    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    int streakCount = 0;
    final currentRun = <DateTime>[];

    DateTime cursor = firstDay;
    while (!cursor.isAfter(lastDay)) {
      final normalized = _dateOnly(cursor);

      if (_isDayFullyCompleted(normalized)) {
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

  int _getCurrentStreak() {
    int streak = 0;
    DateTime cursor = _dateOnly(DateTime.now());

    while (_isDayFullyCompleted(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // --- DATE HELPERS ---

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

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

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

  String _formatLongDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // --- NAV BAR ---

  Widget _buildInteractiveNavBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(Icons.home_rounded, false, () => Navigator.pop(context)),
            _buildNavIcon(Icons.calendar_month_rounded, true, () {}),
            _buildNavIcon(Icons.bar_chart_rounded, false, () {}),
            _buildNavIcon(Icons.settings_rounded, false, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isActive, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon),
      color: isActive ? primaryColor : mutedTextColor,
      iconSize: isActive ? 32 : 28,
      onPressed: onTap,
      splashColor: primaryColor.withOpacity(0.2),
    );
  }
}