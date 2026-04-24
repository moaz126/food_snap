import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/domain/repositories/food_repository.dart';

class GetAllRecords {
  final FoodRepository repository;

  GetAllRecords(this.repository);

  Future<List<FoodRecord>> call() {
    return repository.getAllRecords();
  }
}
