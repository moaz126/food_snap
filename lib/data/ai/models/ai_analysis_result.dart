/// Shared model returned by ALL AI providers.
/// Independent of any specific API response format.
class AiAnalysisResult {
  final String detectedFoodName;
  final List<String> cuisineTags;
  final double confidencePercent;
  final AiNutritionData nutrition;
  final String rawSummary;

  const AiAnalysisResult({
    required this.detectedFoodName,
    required this.cuisineTags,
    required this.confidencePercent,
    required this.nutrition,
    required this.rawSummary,
  });

  /// Parse from JSON — used by all providers
  factory AiAnalysisResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return AiAnalysisResult(
      detectedFoodName: json['detectedFoodName'] as String,
      cuisineTags: List<String>.from(
        json['cuisineTags'] as List,
      ),
      confidencePercent: (json['confidencePercent'] as num).toDouble(),
      nutrition: AiNutritionData.fromJson(
        json['nutrition'] as Map<String, dynamic>,
      ),
      rawSummary: json['rawSummary'] as String,
    );
  }
}

class AiNutritionData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final String? servingSize;

  const AiNutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.servingSize,
  });

  factory AiNutritionData.fromJson(
    Map<String, dynamic> json,
  ) {
    return AiNutritionData(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      servingSize: json['servingSize'] as String?,
    );
  }
}
