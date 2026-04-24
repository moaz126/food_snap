import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/errors/failures.dart';
import 'package:food_snap/domain/usecases/get_all_records.dart';
import 'package:food_snap/presentation/home/bloc/history_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class HistoryCubit extends Cubit<HistoryState> {
  final GetAllRecords getAllRecords;

  HistoryCubit({required this.getAllRecords}) : super(const HistoryInitial());

  Future<void> load() async {
    emit(const HistoryLoading());
    try {
      final records = await getAllRecords();
      if (records.isEmpty) {
        emit(const HistoryEmpty());
      } else {
        emit(HistoryLoaded(records: records));
      }
    } on Failure catch (f) {
      emit(HistoryError(message: f.message));
    } catch (e) {
      emit(HistoryError(message: 'Failed to load history: $e'));
    }
  }
}
