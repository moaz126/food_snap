import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';

class EmptyHistoryState extends StatelessWidget {
  const EmptyHistoryState({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final textSub = palette.textSub;
    final textMuted = palette.textMuted;
    final surface = palette.surface;
    final border = palette.border;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
