import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calendar_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

enum TaskFilter { all, todo, done }

class _MainScreenState extends State<MainScreen> {
  // --- THEME COLORS ---
  final Color bgColor = const Color(0xFF151515);
  final Color primaryColor = const Color(0xFFD4FF00);
  final Color secondaryColor = const Color(0xFFB4A6FF);
  final Color cardColor = const Color(0xFF2A2A2C);
  final Color mutedColor = const Color(0xFF3A3A3C);
  final Color mutedTextColor = const Color(0xFF8E8E93);
  final Color destructiveColor = const Color(0xFFFF453A);

  // --- UI STATE ---
  final TextEditingController _searchController = TextEditingController();
  TaskFilter _selectedFilter = TaskFilter.all;
  String _searchQuery = '';

  // --- LOCAL STATE (READY FOR FIREBASE LATER) ---
  final List<Map<String, dynamic>> dailyTasks = [
    {
      'title': 'Read 30 Pages',
      'subtitle': 'Personal growth',
      'category': 'Mind',
      'type': 'progress',
      'current': 12,
      'total': 30,
      'isDone': false,
      'isPriority': true,
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFB4A6FF),
    },
    {
      'title': 'Drink 2L Water',
      'subtitle': 'Health goal',
      'category': 'Health',
      'type': 'progress',
      'current': 6,
      'total': 8,
      'isDone': false,
      'isPriority': true,
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF56CCF2),
    },
    {
      'title': 'Workout',
      'subtitle': '45 mins',
      'category': 'Fitness',
      'type': 'simple',
      'isDone': false,
      'isPriority': true,
      'icon': Icons.fitness_center_rounded,
      'color': const Color(0xFFFFB86B),
    },
    {
      'title': 'Make the Bed',
      'subtitle': 'Morning routine',
      'category': 'Home',
      'type': 'simple',
      'isDone': true,
      'isPriority': false,
      'icon': Icons.bed_rounded,
      'color': const Color(0xFF7EE6A2),
    },
    {
      'title': 'Meditate',
      'subtitle': '10 minutes',
      'category': 'Mind',
      'type': 'simple',
      'isDone': false,
      'isPriority': false,
      'icon': Icons.self_improvement_rounded,
      'color': const Color(0xFFFF9ACD),
    },
    {
      'title': 'Prepare dinner',
      'subtitle': 'Before 7:00 PM',
      'category': 'Home',
      'type': 'simple',
      'isDone': false,
      'isPriority': false,
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFFFB86B),
    },
    {
      'title': 'Review notes',
      'subtitle': 'Study session',
      'category': 'School',
      'type': 'simple',
      'isDone': false,
      'isPriority': false,
      'icon': Icons.school_rounded,
      'color': const Color(0xFFB4A6FF),
    },
    {
      'title': 'Sleep before 11 PM',
      'subtitle': 'Recovery',
      'category': 'Health',
      'type': 'simple',
      'isDone': false,
      'isPriority': false,
      'icon': Icons.nightlight_round,
      'color': const Color(0xFF8EA7FF),
    },
  ];

  int get completedTasks =>
      dailyTasks.where((task) => task['isDone'] == true).length;

  int get totalTasks => dailyTasks.length;

  double get overallProgress =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  List<Map<String, dynamic>> get priorityTasks =>
      dailyTasks.where((task) => task['isPriority'] == true).toList();

  List<Map<String, dynamic>> get filteredTasks {
    List<Map<String, dynamic>> tasks = List.from(dailyTasks);

    if (_selectedFilter == TaskFilter.todo) {
      tasks = tasks.where((task) => task['isDone'] == false).toList();
    } else if (_selectedFilter == TaskFilter.done) {
      tasks = tasks.where((task) => task['isDone'] == true).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      tasks = tasks.where((task) {
        final title = (task['title'] ?? '').toString().toLowerCase();
        final subtitle = (task['subtitle'] ?? '').toString().toLowerCase();
        final category = (task['category'] ?? '').toString().toLowerCase();
        return title.contains(q) ||
            subtitle.contains(q) ||
            category.contains(q);
      }).toList();
    }

    tasks.sort((a, b) {
      final aDone = a['isDone'] == true;
      final bDone = b['isDone'] == true;

      if (aDone != bDone) {
        return aDone ? 1 : -1; // unfinished first
      }

      final aPriority = a['isPriority'] == true;
      final bPriority = b['isPriority'] == true;

      if (aPriority != bPriority) {
        return aPriority ? -1 : 1; // priority first
      }

      return 0;
    });

    return tasks;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleTask(Map<String, dynamic> task) {
    setState(() {
      task['isDone'] = !(task['isDone'] == true);
    });
  }

  void _showAddTaskPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add task flow coming next.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskPlaceholder,
        backgroundColor: primaryColor,
        child: Icon(Icons.add_rounded, color: bgColor, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(today),
                          const SizedBox(height: 24),
                          _buildOverviewCard(),
                          const SizedBox(height: 20),
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          _buildFilterRow(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Today Focus'),
                          const SizedBox(height: 14),
                          _buildPriorityTaskGrid(),
                          const SizedBox(height: 28),
                          _buildTaskListHeader(),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                  filteredTasks.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                          sliver: SliverList.separated(
                            itemCount: filteredTasks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return _buildTaskCard(task);
                            },
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildInteractiveNavBar(),
    );
  }

  // --- HEADER ---

  Widget _buildHeader(DateTime today) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
              _formatDate(today),
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: mutedTextColor,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildInteractiveIconButton(
              icon: Icons.calendar_month_rounded,
              color: secondaryColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            _buildInteractiveIconButton(
              icon: Icons.notifications_rounded,
              color: primaryColor,
              hasBadge: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications.')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: mutedColor.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily progress',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: mutedTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: '$completedTasks'),
                      TextSpan(
                        text: '/$totalTasks',
                        style: TextStyle(
                          fontSize: 22,
                          color: mutedTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  overallProgress == 1
                      ? 'Everything completed today.'
                      : overallProgress >= 0.5
                          ? 'You are doing great.'
                          : 'Keep the momentum going.',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 10,
                  color: mutedColor,
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: overallProgress),
                  duration: const Duration(milliseconds: 450),
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      color: primaryColor,
                      backgroundColor: Colors.transparent,
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
                Center(
                  child: Text(
                    '${(overallProgress * 100).round()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SEARCH + FILTER ---

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      style: GoogleFonts.nunitoSans(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: 'Search tasks, categories, notes...',
        hintStyle: TextStyle(color: mutedTextColor.withOpacity(0.7)),
        prefixIcon: Icon(Icons.search_rounded, color: mutedTextColor),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: Icon(Icons.close_rounded, color: mutedTextColor),
              )
            : null,
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.35),
            width: 1.8,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        _buildFilterChip(label: 'All', filter: TaskFilter.all),
        const SizedBox(width: 10),
        _buildFilterChip(label: 'To Do', filter: TaskFilter.todo),
        const SizedBox(width: 10),
        _buildFilterChip(label: 'Done', filter: TaskFilter.done),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required TaskFilter filter,
  }) {
    final isActive = _selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? primaryColor
                : mutedColor.withOpacity(0.45),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isActive ? bgColor : Colors.white,
          ),
        ),
      ),
    );
  }

  // --- PRIORITY / FOCUS ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPriorityTaskGrid() {
    if (priorityTasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          'No priority tasks for today.',
          style: GoogleFonts.nunitoSans(
            color: mutedTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return GridView.builder(
      itemCount: priorityTasks.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 120,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final task = priorityTasks[index];
        final bool isDone = task['isDone'] == true;
        final Color accent = task['color'] as Color? ?? primaryColor;

        String trailingText = '';
        if (task['type'] == 'progress') {
          trailingText = '${task['current']}/${task['total']}';
        } else {
          trailingText = isDone ? 'Done' : 'Today';
        }

        return GestureDetector(
          onTap: () => _toggleTask(task),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accent.withOpacity(0.28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        task['icon'] as IconData? ?? Icons.task_alt_rounded,
                        color: accent,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isDone ? primaryColor : mutedTextColor,
                      size: 22,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  task['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDone ? mutedTextColor : Colors.white,
                    decoration:
                        isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trailingText,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- TASK LIST ---

  Widget _buildTaskListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('All Tasks'),
        Text(
          '${filteredTasks.length} shown',
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: mutedTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final bool isDone = task['isDone'] == true;
    final bool isPriority = task['isPriority'] == true;
    final Color accent = task['color'] as Color? ?? primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _toggleTask(task),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: mutedColor.withOpacity(0.45)),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isDone ? primaryColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone ? primaryColor : mutedTextColor,
                    width: 2.4,
                  ),
                ),
                child: isDone
                    ? Icon(Icons.check_rounded, color: bgColor, size: 18)
                    : null,
              ),
              const SizedBox(width: 14),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  task['icon'] as IconData? ?? Icons.task_alt_rounded,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task['title'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDone ? mutedTextColor : Colors.white,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (isPriority)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: secondaryColor.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Focus',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: secondaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${task['subtitle']} • ${task['category']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: mutedTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (task['type'] == 'progress' && !isDone)
                Text(
                  '${task['current']}/${task['total']}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: mutedTextColor.withOpacity(0.8),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: mutedColor.withOpacity(0.45)),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, color: mutedTextColor, size: 34),
            const SizedBox(height: 12),
            Text(
              'No tasks found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try changing your search or selected filter.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: mutedTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE BUTTONS ---

  Widget _buildInteractiveIconButton({
    required IconData icon,
    required Color color,
    bool hasBadge = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: mutedColor.withOpacity(0.5)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              if (hasBadge)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: destructiveColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardColor, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
            _buildNavIcon(Icons.home_rounded, true, () {}),
            _buildNavIcon(Icons.calendar_month_rounded, false, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarScreen(),
                ),
              );
            }),
            _buildNavIcon(Icons.bar_chart_rounded, false, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stats coming soon.')),
              );
            }),
            _buildNavIcon(Icons.settings_rounded, false, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon.')),
              );
            }),
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
      highlightColor: Colors.transparent,
    );
  }

  // --- HELPERS ---

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