import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task_model.dart';

class PriorityTaskGrid extends StatelessWidget {
  final List<TaskModel> tasks;
  final VoidCallback? Function(TaskModel task) onTaskTap;

  const PriorityTaskGrid({
    super.key,
    required this.tasks,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2C),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          'No priority tasks for today.',
          style: GoogleFonts.nunitoSans(
            color: const Color(0xFF8E8E93),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return GridView.builder(
      itemCount: tasks.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 120,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final bool isDone = task.isDone;
        final Color accent = task.color;

        String trailingText = '';
        if (task.type == 'progress') {
          trailingText = '${task.current ?? 0}/${task.total ?? 0}';
        } else {
          trailingText = isDone ? 'Done' : 'Today';
        }

        return GestureDetector(
          onTap: onTaskTap(task),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2C),
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
                        task.icon,
                        color: accent,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isDone
                          ? const Color(0xFFD4FF00)
                          : const Color(0xFF8E8E93),
                      size: 22,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDone ? const Color(0xFF8E8E93) : Colors.white,
                    decoration: isDone ? TextDecoration.lineThrough : null,
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
}