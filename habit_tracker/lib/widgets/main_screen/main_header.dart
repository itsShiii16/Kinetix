import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../shared/app_icon_button.dart';
import '../../screens/calendar_screen.dart';

class MainHeader extends StatelessWidget {
  final DateTime date;

  const MainHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // LEFT: Title + Date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(date),
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),

        // RIGHT: Actions
        Row(
          children: [
            AppIconButton(
              icon: Icons.calendar_month_rounded,
              color: AppColors.secondary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CalendarScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            AppIconButton(
              icon: Icons.notifications_rounded,
              color: AppColors.primary,
              hasBadge: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // --- DATE FORMATTER ---
  String _formatDate(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

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

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}