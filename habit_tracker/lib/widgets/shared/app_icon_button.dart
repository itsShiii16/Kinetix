import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final bool hasBadge;
  final VoidCallback onTap;

  const AppIconButton({
    super.key,
    required this.icon,
    this.color,
    this.hasBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = color ?? AppColors.primary;

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
            border: Border.all(
              color: AppColors.muted.withOpacity(0.5),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: iconColor, size: 24),

              if (hasBadge)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.destructive,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.card,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}