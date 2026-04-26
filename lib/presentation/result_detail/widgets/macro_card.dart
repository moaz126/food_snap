import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';
import 'package:food_snap/domain/entities/food_record.dart';

String _formatNumber(double value) {
  if (value == value.truncate()) {
    return value.toInt().toString();
  }
  return value.toString();
}

class MacroCard extends StatelessWidget {
  final NutritionInfo nutrition;

  const MacroCard({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Macros', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _macroRow('Protein', nutrition.protein, 100, palette.primary),
            _macroRow('Carbs', nutrition.carbs, 300, palette.amber),
            _macroRow('Fat', nutrition.fat, 100, palette.coral),
          ],
        ),
      ),
    );
  }

  Widget _macroRow(String label, double value, double maxRef, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('${_formatNumber(value)} g'),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / maxRef).clamp(0.0, 1.0),
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
