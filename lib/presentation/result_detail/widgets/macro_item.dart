import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';

String _formatNumber(double value) {
  if (value == value.truncate()) {
    return value.toInt().toString();
  }
  return value.toString();
}

class MacroItem extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final Color bgColor;
  final double maxReference;

  const MacroItem({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.bgColor,
    this.maxReference = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatNumber(value)}$unit',
            style: AppTextStyles.h3.copyWith(color: color),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / maxReference).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
