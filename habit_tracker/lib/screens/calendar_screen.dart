import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Kinetix Theme Colors
  final Color bgColor = const Color(0xFF151515);
  final Color primaryColor = const Color(0xFFD4FF00); // Neon Lime
  final Color secondaryColor = const Color(0xFFB4A6FF); // Pastel Purple
  final Color cardColor = const Color(0xFF2A2A2C);
  final Color mutedColor = const Color(0xFF3A3A3C);
  final Color mutedTextColor = const Color(0xFF8E8E93);
  final Color destructiveColor = const Color(0xFFFF453A); // Red

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true, // For the floating nav bar
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildMonthSelector(),
              _buildCalendarGrid(),
              _buildActivitySection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildHeader() {
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
                '12 day streak! 🔥',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
          // Add New Chore/Event Button
          GestureDetector(
            onTap: () {
              // TODO: Trigger Firebase Create functionality for a specific date
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
          Icon(Icons.arrow_back_ios_rounded, color: mutedTextColor, size: 20),
          Text(
            'April 2026', // Updated to current context
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: mutedTextColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
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
          // Days of the week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
              return Expanded(
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
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // Recreated layout matching your mockup using responsive row stacks
          _buildCalendarRow(
            days: ['1', '2', '3', '4', '5', '6', '7'],
            streakStartIdx: 0,
            streakLength: 4,
            streakColor: primaryColor,
          ),
          _buildCalendarRow(
            days: ['8', '9', '10', '11', '12', '13', '14'],
            streakStartIdx: 1,
            streakLength: 5,
            streakColor: secondaryColor,
          ),
          _buildCalendarRow(
            days: ['15', '16', '17', '18', '19', '20', '21'],
            streakStartIdx: -1, // No streak
            streakLength: 0,
            streakColor: Colors.transparent,
          ),
          _buildCalendarRow(
            days: ['22', '23', '24', '25', '26', '27', '28'],
            streakStartIdx: 0,
            streakLength: 3,
            streakColor: primaryColor,
            selectedDay: '24',
          ),
        ],
      ),
    );
  }

  // Helper to build a responsive row with a background streak
  Widget _buildCalendarRow({
    required List<String> days,
    required int streakStartIdx,
    required int streakLength,
    required Color streakColor,
    String? selectedDay,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Streak Bar
          if (streakStartIdx != -1)
            Positioned(
              left: (MediaQuery.of(context).size.width - 96) / 7 * streakStartIdx,
              width: (MediaQuery.of(context).size.width - 96) / 7 * streakLength,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: streakColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: streakColor.withOpacity(0.3)),
                ),
              ),
            ),
          
          // The Numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) {
              bool isStreak = days.indexOf(day) >= streakStartIdx && days.indexOf(day) < streakStartIdx + streakLength;
              bool isSelected = day == selectedDay;

              return Expanded(
                child: Center(
                  child: isSelected
                      ? Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor.withOpacity(0.3), width: 4),
                          ),
                          child: Center(
                            child: Text(
                              day,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: bgColor,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          day,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            fontWeight: isStreak ? FontWeight.w900 : FontWeight.bold,
                            color: isStreak ? streakColor : mutedTextColor,
                          ),
                        ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity for Apr 24',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            title: 'Daily Exercise',
            time: 'Completed at 08:30 AM',
            color: primaryColor,
            isCompleted: true,
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            title: 'Reading Session',
            time: 'Skipped',
            color: secondaryColor,
            isCompleted: false,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(isCompleted ? 1.0 : 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mutedColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
              Column(
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
            ],
          ),
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isCompleted ? primaryColor : destructiveColor,
            size: 28,
          ),
        ],
      ),
    );
  }

  // --- FLOATING NAV BAR ---
  Widget _buildFloatingNavBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context), // Goes back to MainScreen
              child: Icon(Icons.home_rounded, color: mutedTextColor, size: 28),
            ),
            Icon(Icons.calendar_month_rounded, color: primaryColor, size: 32, shadows: [Shadow(color: primaryColor.withOpacity(0.6), blurRadius: 8)]),
            Icon(Icons.bar_chart_rounded, color: mutedTextColor, size: 28),
            Icon(Icons.settings_rounded, color: mutedTextColor, size: 28),
          ],
        ),
      ),
    );
  }
}