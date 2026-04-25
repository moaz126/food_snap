import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';
import 'package:food_snap/core/utils/date_formatter.dart';
import 'package:food_snap/core/utils/image_storage_service.dart';
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
    final palette = context.appPalette;
    final primary = palette.primary;
    final surface = palette.surface;
    final border = palette.border;
    final textColor = palette.text;
    final textSub = palette.textSub;
    final textMuted = palette.textMuted;

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
            FutureBuilder<bool>(
              future: ImageStorageService.imageExists(record.imageUri),
              builder: (context, snapshot) {
                final exists = snapshot.data ?? false;

                if (exists && record.imageUri.isNotEmpty) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(record.imageUri),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                    ),
                  );
                }

                return _buildPlaceholder(context);
              },
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

  Widget _buildPlaceholder(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: palette.primaryBg,
      ),
      child: Icon(
        Icons.restaurant,
        color: palette.primary,
        size: 24,
      ),
    );
  }
}
