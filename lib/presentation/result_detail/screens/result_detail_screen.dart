import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/utils/date_formatter.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/presentation/result_detail/widgets/calories_card.dart';
import 'package:food_snap/presentation/result_detail/widgets/macro_card.dart';
import 'package:food_snap/presentation/result_detail/widgets/nutrition_detail_row.dart';
import 'package:go_router/go_router.dart';

class ResultDetailScreen extends StatelessWidget {
  final FoodRecord record;

  const ResultDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Details'),
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(record.imageUri),
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 220,
                child: Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(record.detectedFoodName, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            'Confidence: ${record.confidencePercent.toStringAsFixed(1)}%',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 4),
          Text(DateFormatter.full(record.createdAt), style: AppTextStyles.caption),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: record.cuisineTags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          CaloriesCard(calories: record.nutrition.calories),
          const SizedBox(height: 12),
          MacroCard(nutrition: record.nutrition),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  NutritionDetailRow(
                    title: 'Fiber',
                    value: '${record.nutrition.fiber?.toStringAsFixed(1) ?? '-'} g',
                  ),
                  NutritionDetailRow(
                    title: 'Sugar',
                    value: '${record.nutrition.sugar?.toStringAsFixed(1) ?? '-'} g',
                  ),
                  NutritionDetailRow(
                    title: 'Sodium',
                    value: '${record.nutrition.sodium?.toStringAsFixed(1) ?? '-'} mg',
                  ),
                  NutritionDetailRow(
                    title: 'Serving',
                    value: record.nutrition.servingSize ?? '-',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(record.rawApiSummary),
            ),
          ),
        ],
      ),
    );
  }
}
