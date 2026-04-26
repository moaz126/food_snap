import 'package:flutter_test/flutter_test.dart';
import 'package:food_snap/data/ai/models/ai_analysis_result.dart';

void main() {
  group('AiAnalysisResult', () {
    final validJson = <String, dynamic>{
      'detectedFoodName': 'Caesar Salad',
      'cuisineTags': ['American', 'Healthy'],
      'confidencePercent': 88.0,
      'nutrition': <String, dynamic>{
        'calories': 180.0,
        'protein': 6.0,
        'carbs': 14.0,
        'fat': 12.0,
        'fiber': 3.0,
        'sugar': 2.0,
        'sodium': 380.0,
        'servingSize': '1 bowl',
      },
      'rawSummary': 'Caesar salad with dressing',
    };

    test('fromJson parses valid response correctly', () {
      final result = AiAnalysisResult.fromJson(validJson);

      expect(result.detectedFoodName, 'Caesar Salad');
      expect(result.cuisineTags, ['American', 'Healthy']);
      expect(result.confidencePercent, 88.0);
      expect(result.nutrition.calories, 180.0);
      expect(result.nutrition.servingSize, '1 bowl');
    });

    test('fromJson handles integer numbers as double', () {
      final jsonWithInts = Map<String, dynamic>.from(validJson)
        ..['confidencePercent'] = 88 // int instead of double
        ..['nutrition'] = <String, dynamic>{
          'calories': 180,
          'protein': 6,
          'carbs': 14,
          'fat': 12,
          'fiber': 3,
          'sugar': 2,
          'sodium': 380,
          'servingSize': '1 bowl',
        };

      final result = AiAnalysisResult.fromJson(jsonWithInts);

      expect(result.confidencePercent, 88.0);
      expect(result.nutrition.calories, 180.0);
    });

    test('fromJson throws on invalid json', () {
      expect(
        () => AiAnalysisResult.fromJson({}),
        throwsA(isA<TypeError>()),
      );
    });

    test('nutrition nullable fields handle null', () {
      final jsonWithNulls = Map<String, dynamic>.from(validJson);
      (jsonWithNulls['nutrition'] as Map)['fiber'] = null;
      (jsonWithNulls['nutrition'] as Map)['sugar'] = null;

      final result = AiAnalysisResult.fromJson(jsonWithNulls);

      expect(result.nutrition.fiber, isNull);
    });
  });
}
