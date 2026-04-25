import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/errors/failures.dart';
import 'package:food_snap/domain/usecases/delete_record.dart';
import 'package:food_snap/domain/usecases/get_all_records.dart';
import 'package:food_snap/presentation/home/bloc/history_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class HistoryCubit extends Cubit<HistoryState> {
  final GetAllRecords _getAllRecords;

  HistoryCubit({required GetAllRecords getAllRecords})
      : _getAllRecords = getAllRecords,
        super(const HistoryInitial());

  Future<void> loadHistory() async {
    emit(const HistoryLoading());
    try {
      final records = await _getAllRecords();
      if (records.isEmpty) {
        emit(const HistoryEmpty());
      } else {
        emit(HistoryLoaded(records: records));
      }
    } on DatabaseException catch (e) {
      emit(HistoryError(message: e.message));
    } catch (e) {
      emit(const HistoryError(message: 'Failed to load history.'));
    }
  }

  Future<void> refresh() async {
    // Don't emit Loading — keep the current list visible for better UX
    try {
      final records = await _getAllRecords();
      if (records.isEmpty) {
        emit(const HistoryEmpty());
      } else {
        emit(HistoryLoaded(records: records));
      }
    } on DatabaseException catch (e) {
      emit(HistoryError(message: e.message));
    } catch (e) {
      emit(const HistoryError(message: 'Failed to refresh history.'));
    }
  }

  Future<void> deleteRecord(
    String id,
    DeleteRecord deleteRecordUseCase,
  ) async {
    try {
      await deleteRecordUseCase(id);
      await refresh();
    } catch (e) {
      emit(const HistoryError(message: 'Failed to delete record.'));
    }
  }
}
