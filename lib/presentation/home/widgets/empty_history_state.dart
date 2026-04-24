import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_colors.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';

class EmptyHistoryState extends StatelessWidget {
  const EmptyHistoryState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;
    final textMuted =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(Icons.restaurant_menu_rounded, size: 44, color: textMuted),
          const SizedBox(height: 10),
          Text(
            'No scans yet',
            style: AppTextStyles.label.copyWith(color: textSub),
          ),
          const SizedBox(height: 4),
          Text(
            'Snap a meal to see nutrition details here',
            style: AppTextStyles.caption.copyWith(color: textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
