import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';

class NutritionDetailRow extends StatelessWidget {
  final String title;
  final String value;

  const NutritionDetailRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
