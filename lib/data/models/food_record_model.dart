import 'dart:convert';

import 'package:food_snap/domain/entities/food_record.dart';

class FoodRecordModel {
  FoodRecordModel._();

  static Map<String, dynamic> toDbMap(FoodRecord record) {
    return {
      'id': record.id,
      'image_uri': record.imageUri,
      'detected_food_name': record.detectedFoodName,
      'cuisine_tags': jsonEncode(record.cuisineTags),
      'confidence_percent': record.confidencePercent,
      'calories': record.nutrition.calories,
      'protein': record.nutrition.protein,
      'carbs': record.nutrition.carbs,
      'fat': record.nutrition.fat,
      'fiber': record.nutrition.fiber,
      'sugar': record.nutrition.sugar,
      'sodium': record.nutrition.sodium,
      'serving_size': record.nutrition.servingSize,
      'raw_api_summary': record.rawApiSummary,
      'created_at': record.createdAt.toIso8601String(),
    };
  }

  static FoodRecord fromDbMap(Map<String, dynamic> map) {
    return FoodRecord(
      id: map['id'] as String,
      imageUri: map['image_uri'] as String,
      detectedFoodName: map['detected_food_name'] as String,
      cuisineTags: List<String>.from(
        jsonDecode(map['cuisine_tags'] as String) as List<dynamic>,
      ),
      confidencePercent: (map['confidence_percent'] as num).toDouble(),
      nutrition: NutritionInfo(
        calories: (map['calories'] as num).toDouble(),
        protein: (map['protein'] as num).toDouble(),
        carbs: (map['carbs'] as num).toDouble(),
        fat: (map['fat'] as num).toDouble(),
        fiber: (map['fiber'] as num?)?.toDouble(),
        sugar: (map['sugar'] as num?)?.toDouble(),
        sodium: (map['sodium'] as num?)?.toDouble(),
        servingSize: map['serving_size'] as String?,
      ),
      rawApiSummary: map['raw_api_summary'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
