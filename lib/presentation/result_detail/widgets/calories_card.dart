import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_colors.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';

class CaloriesCard extends StatelessWidget {
  final double calories;

  const CaloriesCard({super.key, required this.calories});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calories', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightAmberBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${calories.toStringAsFixed(0)} kcal',
                style: AppTextStyles.h2.copyWith(color: AppColors.lightAmber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
