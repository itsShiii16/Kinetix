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
import 'archive_screen.dart';
import 'edit_task_screen.dart';

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
          .where(
            (task) =>
                task.category.toLowerCase() ==
                selectedCategoryLabel.toLowerCase(),
          )
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

  Future<void> _openAddTaskScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
  }

  Future<void> _openEditTaskScreen(TaskModel task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
    );
  }

  Future<void> _openArchiveScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ArchiveScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskScreen,
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

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load tasks.',
                  style: TextStyle(color: AppColors.mutedText),
                ),
              );
            }

            final tasks = snapshot.data ?? [];
            final filteredTasks = _filterTasks(tasks);
            final completedTasks = tasks.where((task) => task.isDone).length;
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
                          onTaskTap: (task) => () => _openEditTaskScreen(task),
                        ),
                        const SizedBox(height: 28),
                        _buildTaskGroupsHeader(),
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
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                          child: _buildEmptyState(),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                        sliver: SliverList.separated(
                          itemCount: filteredTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return Dismissible(
                              key: ValueKey(task.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) async {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppColors.card,
                                    title: const Text(
                                      'Move task to Archive?',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      'You can restore it later from the Archive screen.',
                                      style: TextStyle(
                                        color: AppColors.mutedText,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: AppColors.mutedText,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Archive'),
                                      ),
                                    ],
                                  ),
                                );

                                if (result == true) {
                                  await _taskService.softDeleteTask(task.id);

                                  if (!mounted) return false;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Task moved to Archive',
                                      ),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () {
                                          _taskService.restoreTask(task.id);
                                        },
                                      ),
                                    ),
                                  );
                                }

                                return false;
                              },
                              background: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.destructive,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Icon(
                                  Icons.archive_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              child: GestureDetector(
                                onLongPress: () => _toggleTask(task),
                                child: TaskCard(
                                  task: task,
                                  onTap: () => _openEditTaskScreen(task),
                                ),
                              ),
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

  Widget _buildTaskGroupsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('Task Groups'),
        TextButton.icon(
          onPressed: _openArchiveScreen,
          icon: Icon(
            Icons.archive_outlined,
            color: AppColors.secondary,
            size: 18,
          ),
          label: Text(
            'Archive',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: AppColors.muted.withOpacity(0.45)),
            ),
          ),
        ),
      ],
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
        hintStyle: TextStyle(color: AppColors.mutedText.withOpacity(0.7)),
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.mutedText),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: Icon(Icons.close_rounded, color: AppColors.mutedText),
              )
            : null,
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.35),
            width: 1.8,
          ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.muted.withOpacity(0.45)),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, color: AppColors.mutedText, size: 34),
          const SizedBox(height: 12),
          Text(
            'No tasks here yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedCategoryLabel == 'All'
                ? 'Try adding a task to get started.'
                : 'No $selectedCategoryLabel tasks found.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}