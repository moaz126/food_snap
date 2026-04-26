import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';

class AnalyzeButton extends StatelessWidget {
  final bool canAnalyze;
  final bool isLoading;
  final VoidCallback? onTap;

  const AnalyzeButton({
    super.key,
    required this.canAnalyze,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canAnalyze && !isLoading ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          disabledBackgroundColor: palette.primary.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Analyze Food',
          style: AppTextStyles.label.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
