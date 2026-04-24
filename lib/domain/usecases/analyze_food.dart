import 'dart:io';

import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/domain/repositories/food_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AnalyzeFood {
  final FoodRepository repository;

  AnalyzeFood(this.repository);

  Future<FoodRecord> call(File imageFile) {
    return repository.analyzeFood(imageFile);
  }
}
