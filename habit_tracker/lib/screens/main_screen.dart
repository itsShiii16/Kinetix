import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';
import '../widgets/main_screen/category_tabs.dart';
import '../widgets/main_screen/main_header.dart';
import '../widgets/main_screen/overview_card.dart';
import '../widgets/main_screen/priority_task_grid.dart';
import '../widgets/main_screen/task_card.dart';
import '../widgets/shared/app_bottom_nav_bar.dart';
import 'add_task_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TaskService _taskService = TaskService();

  TaskCategoryTab _selectedTab = TaskCategoryTab.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get selectedCategoryLabel => CategoryTabs.labelFor(_selectedTab);

  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    List<TaskModel> filtered = List.from(tasks);

    if (_selectedTab != TaskCategoryTab.all) {
      filtered = filtered
          .where((task) =>
              task.category.toLowerCase() ==
              selectedCategoryLabel.toLowerCase())
          .toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(query) ||
            task.subtitle.toLowerCase().contains(query) ||
            task.category.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> _toggleTask(TaskModel task) async {
    await _taskService.toggleTaskCompletion(task);
  }

  void _showAddTaskPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add task UI next step')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        );
      },

        backgroundColor: AppColors.primary,
        child: Icon(Icons.add_rounded, color: AppColors.bg, size: 28),
      ),
      body: SafeArea(
        child: StreamBuilder<List<TaskModel>>(
          stream: _taskService.getActiveTasks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = snapshot.data ?? [];

            final filteredTasks = _filterTasks(tasks);

            final completedTasks =
                tasks.where((task) => task.isDone).length;

            final totalTasks = tasks.length;

            final priorityTasks =
                tasks.where((task) => task.isPriority).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MainHeader(date: DateTime.now()),
                        const SizedBox(height: 24),
                        OverviewCard(
                          completedTasks: completedTasks,
                          totalTasks: totalTasks,
                        ),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Today Focus'),
                        const SizedBox(height: 14),
                        PriorityTaskGrid(
                          tasks: priorityTasks,
                          onTaskTap: (task) => () => _toggleTask(task),
                        ),
                        const SizedBox(height: 28),
                        _buildSectionTitle('Task Groups'),
                        const SizedBox(height: 14),
                        CategoryTabs(
                          selectedTab: _selectedTab,
                          onTabSelected: (tab) {
                            setState(() {
                              _selectedTab = tab;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTaskListHeader(filteredTasks),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                filteredTasks.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(24, 0, 24, 140),
                          child: _buildEmptyState(),
                        ),
                      )
                    : SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(24, 0, 24, 140),
                        sliver: SliverList.separated(
                          itemCount: filteredTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () => _toggleTask(task),
                            );
                          },
                        ),
                      ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

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
        hintText: 'Search tasks...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTaskListHeader(List<TaskModel> tasks) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          selectedCategoryLabel == 'All'
              ? 'All Tasks'
              : '$selectedCategoryLabel Tasks',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          '${tasks.length} shown',
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No tasks yet. Tap + to add one.',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}