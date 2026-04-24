import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/utils/date_formatter.dart';
import 'package:food_snap/domain/entities/food_record.dart';

class FoodHistoryTile extends StatelessWidget {
  final FoodRecord record;
  final VoidCallback onTap;

  const FoodHistoryTile({
    super.key,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(record.imageUri),
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
          ),
        ),
        title: Text(record.detectedFoodName, style: AppTextStyles.label),
        subtitle: Text(
          '${record.nutrition.calories.toStringAsFixed(0)} kcal • ${DateFormatter.short(record.createdAt)}',
          style: AppTextStyles.caption,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
