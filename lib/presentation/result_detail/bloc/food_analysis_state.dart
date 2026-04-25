import 'package:equatable/equatable.dart';
import 'package:food_snap/domain/entities/food_record.dart';

enum FoodAnalysisErrorType {
  noInternet,
  timeout,
  invalidResponse,
  imageProcessing,
  unknown,
}

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

  const FoodAnalysisSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

class FoodAnalysisError extends FoodAnalysisState {
  final String message;
  final FoodAnalysisErrorType errorType;

  const FoodAnalysisError({
    required this.message,
    required this.errorType,
  });

  @override
  List<Object?> get props => [message, errorType];
}
