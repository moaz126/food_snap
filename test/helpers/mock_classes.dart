import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:food_snap/domain/repositories/food_repository.dart';
import 'package:food_snap/domain/usecases/analyze_food.dart';
import 'package:food_snap/domain/usecases/get_all_records.dart';
import 'package:food_snap/domain/usecases/get_record_by_id.dart';
import 'package:food_snap/domain/usecases/delete_record.dart';

class MockAnalyzeFood extends Mock implements AnalyzeFood {}

class MockGetAllRecords extends Mock implements GetAllRecords {}

class MockGetRecordById extends Mock implements GetRecordById {}

class MockDeleteRecord extends Mock implements DeleteRecord {}

class MockFoodRepository extends Mock implements FoodRepository {}

/// Register fallback values for mocktail.
/// Call this in setUpAll() in any test file that passes File as an argument.
void registerFallbacks() {
  registerFallbackValue(File(''));
}
