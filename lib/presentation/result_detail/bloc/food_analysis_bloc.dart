import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/errors/failures.dart';
import 'package:food_snap/domain/usecases/analyze_food.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_event.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class FoodAnalysisBloc extends Bloc<FoodAnalysisEvent, FoodAnalysisState> {
  final AnalyzeFood analyzeFood;

  FoodAnalysisBloc({required this.analyzeFood})
      : super(const FoodAnalysisInitial()) {
    on<AnalyzeFoodEvent>(_onAnalyzeFood);
    on<ResetAnalysisEvent>(_onReset);
  }

  Future<void> _onAnalyzeFood(
    AnalyzeFoodEvent event,
    Emitter<FoodAnalysisState> emit,
  ) async {
    emit(const FoodAnalysisLoading());
    try {
      final record = await analyzeFood(event.imageFile);
      emit(FoodAnalysisSuccess(record));
    } on SocketException catch (_) {
      emit(
        const FoodAnalysisError(
          message: 'No internet connection. Check your network and try again.',
          errorType: FoodAnalysisErrorType.noInternet,
        ),
      );
    } on TimeoutException catch (_) {
      emit(
        const FoodAnalysisError(
          message: 'Analysis timed out. Please try again.',
          errorType: FoodAnalysisErrorType.timeout,
        ),
      );
    } on FormatException catch (_) {
      emit(
        const FoodAnalysisError(
          message: 'Could not analyze this image. Try a clearer photo.',
          errorType: FoodAnalysisErrorType.invalidResponse,
        ),
      );
    } on Failure catch (f) {
      emit(
        FoodAnalysisError(
          message: f.message,
          errorType: FoodAnalysisErrorType.imageProcessing,
        ),
      );
    } catch (e) {
      emit(
        const FoodAnalysisError(
          message: 'Something went wrong. Please try again.',
          errorType: FoodAnalysisErrorType.unknown,
        ),
      );
    }
  }

  void _onReset(
    ResetAnalysisEvent event,
    Emitter<FoodAnalysisState> emit,
  ) {
    emit(const FoodAnalysisInitial());
  }
}
