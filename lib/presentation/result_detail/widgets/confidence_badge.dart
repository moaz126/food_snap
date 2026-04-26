import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';

class ConfidenceBadge extends StatelessWidget {
  final double percent;

  const ConfidenceBadge({
    super.key,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    final Color bgColor;
    final Color textColor;
    final IconData icon;

    if (percent >= 90) {
      bgColor = palette.greenBg;
      textColor = palette.green;
      icon = Icons.check_circle_rounded;
    } else if (percent >= 70) {
      bgColor = palette.amberBg;
      textColor = palette.amber;
      icon = Icons.info_rounded;
    } else {
      bgColor = palette.coralBg;
      textColor = palette.coral;
      icon = Icons.warning_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 14),
          const SizedBox(width: 4),
          Text(
            '${percent.toInt()}% match',
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
