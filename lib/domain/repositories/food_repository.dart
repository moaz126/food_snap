import 'dart:io';

import 'package:food_snap/domain/entities/food_record.dart';

abstract class FoodRepository {
  Future<FoodRecord> analyzeFood(File imageFile);
  Future<List<FoodRecord>> getAllRecords();
  Future<FoodRecord?> getRecordById(String id);
  Future<void> deleteRecord(String id);
  Future<void> clearAll();
}
