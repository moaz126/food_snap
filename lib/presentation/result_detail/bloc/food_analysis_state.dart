import 'package:equatable/equatable.dart';
import 'package:food_snap/domain/entities/food_record.dart';

abstract class FoodAnalysisState extends Equatable {
  const FoodAnalysisState();

  @override
  List<Object?> get props => [];
}

class FoodAnalysisInitial extends FoodAnalysisState {
  const FoodAnalysisInitial();
}

class FoodAnalysisLoading extends FoodAnalysisState {
  const FoodAnalysisLoading();
}

class FoodAnalysisSuccess extends FoodAnalysisState {
  final FoodRecord record;

  const FoodAnalysisSuccess({required this.record});

  @override
  List<Object?> get props => [record];
}

class FoodAnalysisError extends FoodAnalysisState {
  final String message;

  const FoodAnalysisError({required this.message});

  @override
  List<Object?> get props => [message];
}
