import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/domain/repositories/food_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetAllRecords {
  final FoodRepository repository;

  GetAllRecords(this.repository);

  Future<List<FoodRecord>> call() {
    return repository.getAllRecords();
  }
}
