import 'package:food_snap/domain/repositories/food_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeleteRecord {
  final FoodRepository _repository;

  const DeleteRecord(this._repository);

  Future<void> call(String id) async {
    return _repository.deleteRecord(id);
  }
}
