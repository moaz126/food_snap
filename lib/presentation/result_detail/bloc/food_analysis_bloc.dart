import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/data/ai/ai_provider.dart';
import 'package:food_snap/core/errors/failures.dart';
import 'package:food_snap/domain/usecases/analyze_food.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_event.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class FoodAnalysisBloc extends Bloc<FoodAnalysisEvent, FoodAnalysisState> {
  final AnalyzeFood _analyzeFood;

  FoodAnalysisBloc({required AnalyzeFood analyzeFood})
      : _analyzeFood = analyzeFood,
        super(const FoodAnalysisInitial()) {
    on<AnalyzeFoodEvent>(_onAnalyzeFood);
    on<ResetAnalysisEvent>(_onReset);
  }

  Future<void> _onAnalyzeFood(
    AnalyzeFoodEvent event,
    Emitter<FoodAnalysisState> emit,
  ) async {
    // Guard: ignore concurrent requests
    if (state is FoodAnalysisLoading) return;

    emit(const FoodAnalysisLoading());

    try {
      final record = await _analyzeFood(event.imageFile);
      emit(FoodAnalysisSuccess(record));
    } on AiProviderException catch (e) {
      emit(FoodAnalysisError(
        message: e.message,
        errorType: _mapErrorType(e.type),
      ));
    } on DatabaseException catch (e) {
      // DB failure that escaped the repository (shouldn't happen
      // since analyzeFood swallows DB errors, but handle defensively)
      emit(FoodAnalysisError(
        message: e.message,
        errorType: FoodAnalysisErrorType.unknown,
      ));
    } catch (e) {
      emit(const FoodAnalysisError(
        message: 'Something went wrong. Please try again.',
        errorType: FoodAnalysisErrorType.unknown,
      ));
    }
  }

  void _onReset(
    ResetAnalysisEvent event,
    Emitter<FoodAnalysisState> emit,
  ) {
    emit(const FoodAnalysisInitial());
  }

  FoodAnalysisErrorType _mapErrorType(AiProviderErrorType type) {
    return switch (type) {
      AiProviderErrorType.noInternet => FoodAnalysisErrorType.noInternet,
      AiProviderErrorType.timeout => FoodAnalysisErrorType.timeout,
      AiProviderErrorType.invalidResponse =>
        FoodAnalysisErrorType.invalidResponse,
      AiProviderErrorType.imageProcessing =>
        FoodAnalysisErrorType.imageProcessing,
      AiProviderErrorType.rateLimitExceeded ||
      AiProviderErrorType.unauthorized ||
      AiProviderErrorType.unknown =>
        FoodAnalysisErrorType.unknown,
    };
  }
}
