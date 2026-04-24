import 'package:equatable/equatable.dart';

class NutritionInfo extends Equatable {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final String? servingSize;

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.servingSize,
  });

  @override
  List<Object?> get props => [
        calories,
        protein,
        carbs,
        fat,
        fiber,
        sugar,
        sodium,
        servingSize,
      ];
}

class FoodRecord extends Equatable {
  final String id;
  final String imageUri;
  final String detectedFoodName;
  final List<String> cuisineTags;
  final double confidencePercent;
  final NutritionInfo nutrition;
  final String rawApiSummary;
  final DateTime createdAt;

  const FoodRecord({
    required this.id,
    required this.imageUri,
    required this.detectedFoodName,
    required this.cuisineTags,
    required this.confidencePercent,
    required this.nutrition,
    required this.rawApiSummary,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        imageUri,
        detectedFoodName,
        cuisineTags,
        confidencePercent,
        nutrition,
        rawApiSummary,
        createdAt,
      ];
}
