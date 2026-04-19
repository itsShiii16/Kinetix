import 'package:flutter/material.dart';

import '../../screens/calendar_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/statistics_screen.dart';
import '../../utils/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.95),
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
            _buildNavIcon(
              context,
              icon: Icons.home_rounded,
              index: 0,
              onTap: () => _navigateTo(context, 0),
            ),
            _buildNavIcon(
              context,
              icon: Icons.calendar_month_rounded,
              index: 1,
              onTap: () => _navigateTo(context, 1),
            ),
            _buildNavIcon(
              context,
              icon: Icons.bar_chart_rounded,
              index: 2,
              onTap: () => _navigateTo(context, 2),
            ),
            _buildNavIcon(
              context,
              icon: Icons.settings_rounded,
              index: 3,
              onTap: () => _navigateTo(context, 3),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, int targetIndex) {
    if (targetIndex == currentIndex) return;

    Widget targetScreen;

    switch (targetIndex) {
      case 0:
        targetScreen = const MainScreen();
        break;
      case 1:
        targetScreen = const CalendarScreen();
        break;
      case 2:
        targetScreen = const StatisticsScreen();
        break;
      case 3:
        targetScreen = const SettingsScreen();
        break;
      default:
        targetScreen = const MainScreen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  Widget _buildNavIcon(
    BuildContext context, {
    required IconData icon,
    required int index,
    required VoidCallback onTap,
  }) {
    final bool isActive = currentIndex == index;

    return IconButton(
      icon: Icon(icon),
      color: isActive ? AppColors.primary : AppColors.mutedText,
      iconSize: isActive ? 32 : 28,
      onPressed: onTap,
      splashColor: AppColors.primary.withOpacity(0.2),
      highlightColor: Colors.transparent,
    );
  }
}