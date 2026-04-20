import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';
import '../utils/app_colors.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final TaskService _taskService = TaskService();

  Future<void> _restoreTask(TaskModel task) async {
    await _taskService.restoreTask(task.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task restored to active list')),
    );
  }

  Future<void> _hardDeleteTask(TaskModel task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Delete forever?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'This will permanently remove the task and its history.',
            style: TextStyle(color: AppColors.mutedText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.mutedText),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.destructive),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await _taskService.hardDeleteTask(task.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task permanently deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: Colors.white,
        title: const Text('Archive'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _taskService.getDeletedTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load archived tasks.',
                style: GoogleFonts.nunitoSans(color: Colors.white),
              ),
            );
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.archive_outlined,
                      size: 48,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No archived tasks',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tasks you archive will appear here.\nYou can restore them anytime.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        color: AppColors.mutedText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = tasks[index];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.muted.withOpacity(0.45),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: task.color.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        task.icon,
                        color: task.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${task.subtitle} • ${task.category}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mutedText,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ACTIONS
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _restoreTask(task),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.bg,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                child: const Text('Restore'),
                              ),
                              const SizedBox(width: 10),
                              TextButton(
                                onPressed: () => _hardDeleteTask(task),
                                child: Text(
                                  'Delete Forever',
                                  style: TextStyle(
                                    color: AppColors.destructive,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}