import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return SizedBox(
      height: 240,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 64,
              color: palette.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No scans yet',
              style: AppTextStyles.label.copyWith(color: palette.text),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyze your first meal above',
              style: AppTextStyles.caption.copyWith(color: palette.textSub),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
