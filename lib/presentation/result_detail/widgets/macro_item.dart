import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';

class MacroItem extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final Color bgColor;

  const MacroItem({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.bgColor,
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
            '${value.toStringAsFixed(1)}$unit',
            style: AppTextStyles.h3.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
