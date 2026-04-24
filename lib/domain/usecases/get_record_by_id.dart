import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/domain/repositories/food_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetRecordById {
  final FoodRepository repository;

  GetRecordById(this.repository);

  Future<FoodRecord?> call(String id) {
    return repository.getRecordById(id);
  }
}
