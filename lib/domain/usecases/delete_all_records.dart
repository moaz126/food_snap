import 'package:food_snap/domain/repositories/food_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeleteAllRecords {
  final FoodRepository _repository;

  const DeleteAllRecords(this._repository);

  Future<void> call() async {
    return _repository.clearAll();
  }
}
