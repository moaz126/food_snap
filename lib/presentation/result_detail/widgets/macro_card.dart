import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/domain/entities/food_record.dart';

class MacroCard extends StatelessWidget {
  final NutritionInfo nutrition;

  const MacroCard({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Macros', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _macroRow('Protein', '${nutrition.protein.toStringAsFixed(1)} g'),
            _macroRow('Carbs', '${nutrition.carbs.toStringAsFixed(1)} g'),
            _macroRow('Fat', '${nutrition.fat.toStringAsFixed(1)} g'),
          ],
        ),
      ),
    );
  }

  Widget _macroRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key),
          Text(value),
        ],
      ),
    );
  }
}
