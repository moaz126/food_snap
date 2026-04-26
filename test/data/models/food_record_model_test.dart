import 'package:flutter_test/flutter_test.dart';
import 'package:food_snap/data/models/food_record_model.dart';

void main() {
  group('FoodRecordModel', () {
    final testJson = <String, dynamic>{
      'id': 'test-id-123',
      'image_uri': '/documents/food_images/test.jpg',
      'detected_food_name': 'Margherita Pizza',
      'cuisine_tags': '["Italian","Vegetarian"]',
      'confidence_percent': 94.0,
      'calories': 285.0,
      'protein': 9.0,
      'carbs': 36.0,
      'fat': 10.0,
      'fiber': 2.0,
      'sugar': 4.0,
      'sodium': 520.0,
      'serving_size': '1 slice',
      'raw_api_summary': 'Margherita pizza slice',
      'created_at': '2026-04-24T10:00:00.000Z',
    };

    test('fromDbMap creates correct FoodRecord', () {
      final record = FoodRecordModel.fromDbMap(testJson);

      expect(record.id, 'test-id-123');
      expect(record.detectedFoodName, 'Margherita Pizza');
      expect(record.cuisineTags, ['Italian', 'Vegetarian']);
      expect(record.confidencePercent, 94.0);
      expect(record.nutrition.calories, 285.0);
      expect(record.nutrition.protein, 9.0);
      expect(record.nutrition.fiber, 2.0);
      expect(record.nutrition.servingSize, '1 slice');
    });

    test('toDbMap produces correct map', () {
      final record = FoodRecordModel.fromDbMap(testJson);
      final map = FoodRecordModel.toDbMap(record);

      expect(map['id'], 'test-id-123');
      expect(map['detected_food_name'], 'Margherita Pizza');
      expect(map['calories'], 285.0);
      expect(map['confidence_percent'], 94.0);
    });

    test('cuisine_tags JSON string decoded correctly', () {
      final record = FoodRecordModel.fromDbMap(testJson);

      expect(record.cuisineTags.length, 2);
      expect(record.cuisineTags.first, 'Italian');
    });

    test('nullable fields handle null correctly', () {
      final jsonWithNulls = Map<String, dynamic>.from(testJson)
        ..['fiber'] = null
        ..['sugar'] = null
        ..['sodium'] = null
        ..['serving_size'] = null;

      final record = FoodRecordModel.fromDbMap(jsonWithNulls);

      expect(record.nutrition.fiber, isNull);
      expect(record.nutrition.sugar, isNull);
      expect(record.nutrition.servingSize, isNull);
    });
  });
}
