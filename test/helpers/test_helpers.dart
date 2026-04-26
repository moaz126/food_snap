import 'package:food_snap/domain/entities/food_record.dart';

/// Factory function for creating a [FoodRecord] with sensible defaults.
/// Override individual fields by passing named arguments.
FoodRecord createTestRecord({
  String id = 'test-id',
  String foodName = 'Test Food',
  double calories = 300,
  double confidence = 90,
}) {
  return FoodRecord(
    id: id,
    imageUri: '/test/image.jpg',
    detectedFoodName: foodName,
    cuisineTags: const ['Test'],
    confidencePercent: confidence,
    nutrition: NutritionInfo(
      calories: calories,
      protein: 10,
      carbs: 30,
      fat: 8,
    ),
    rawApiSummary: 'Test summary',
    createdAt: DateTime(2026, 4, 24),
  );
}
