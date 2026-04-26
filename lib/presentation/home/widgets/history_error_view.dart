import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';

class HistoryErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const HistoryErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return SizedBox(
      height: 240,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: palette.coral, size: 48),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                style: AppTextStyles.body.copyWith(color: palette.textSub),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: Icon(Icons.refresh, color: palette.primary),
              label: Text(
                'Try Again',
                style: AppTextStyles.label.copyWith(color: palette.primary),
              ),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
