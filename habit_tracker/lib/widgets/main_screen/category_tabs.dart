import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';

enum TaskCategoryTab { all, lifestyle, school, work, home }

class CategoryTabs extends StatelessWidget {
  final TaskCategoryTab selectedTab;
  final ValueChanged<TaskCategoryTab> onTabSelected;

  const CategoryTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabChip('All', TaskCategoryTab.all),
          const SizedBox(width: 10),
          _buildTabChip('Lifestyle', TaskCategoryTab.lifestyle),
          const SizedBox(width: 10),
          _buildTabChip('School', TaskCategoryTab.school),
          const SizedBox(width: 10),
          _buildTabChip('Work', TaskCategoryTab.work),
          const SizedBox(width: 10),
          _buildTabChip('Home', TaskCategoryTab.home),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, TaskCategoryTab tab) {
    final bool isActive = selectedTab == tab;

    return GestureDetector(
      onTap: () => onTabSelected(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.muted.withOpacity(0.45),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isActive ? AppColors.bg : Colors.white,
          ),
        ),
      ),
    );
  }

  static String labelFor(TaskCategoryTab tab) {
    switch (tab) {
      case TaskCategoryTab.all:
        return 'All';
      case TaskCategoryTab.lifestyle:
        return 'Lifestyle';
      case TaskCategoryTab.school:
        return 'School';
      case TaskCategoryTab.work:
        return 'Work';
      case TaskCategoryTab.home:
        return 'Home';
    }
  }
}