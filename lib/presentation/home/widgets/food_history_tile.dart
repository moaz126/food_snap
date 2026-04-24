import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: record.imageUri.isNotEmpty
                  ? Image.file(
                      File(record.imageUri),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface2 : AppColors.lightPrimaryBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 28,
                          color: textMuted,
                        ),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface2 : AppColors.lightPrimaryBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.restaurant_rounded,
                        size: 28,
                        color: textMuted,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.detectedFoodName,
                    style: AppTextStyles.label.copyWith(color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.relative(record.createdAt),
                    style: AppTextStyles.caption.copyWith(color: textSub),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.nutrition.calories.toStringAsFixed(0),
                  style: AppTextStyles.label.copyWith(
                    color: primary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'kcal',
                  style: AppTextStyles.caption.copyWith(color: primary),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}
