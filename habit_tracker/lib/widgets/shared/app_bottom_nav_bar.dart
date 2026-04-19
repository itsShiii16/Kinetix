import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../screens/calendar_screen.dart';

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
              onTap: () {},
            ),
            _buildNavIcon(
              context,
              icon: Icons.calendar_month_rounded,
              index: 1,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CalendarScreen(),
                  ),
                );
              },
            ),
            _buildNavIcon(
              context,
              icon: Icons.bar_chart_rounded,
              index: 2,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stats coming soon')),
                );
              },
            ),
            _buildNavIcon(
              context,
              icon: Icons.settings_rounded,
              index: 3,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              },
            ),
          ],
        ),
      ),
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