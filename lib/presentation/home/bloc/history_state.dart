import 'package:equatable/equatable.dart';
import 'package:food_snap/domain/entities/food_record.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<FoodRecord> records;

  const HistoryLoaded({required this.records});

  @override
  List<Object?> get props => [records];
}

class HistoryEmpty extends HistoryState {
  const HistoryEmpty();
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
