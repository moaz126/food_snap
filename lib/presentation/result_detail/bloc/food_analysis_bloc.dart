import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/errors/failures.dart';
import 'package:food_snap/domain/usecases/analyze_food.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_event.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_state.dart';

class FoodAnalysisBloc extends Bloc<FoodAnalysisEvent, FoodAnalysisState> {
  final AnalyzeFood analyzeFood;

  FoodAnalysisBloc({required this.analyzeFood}) : super(const FoodAnalysisInitial()) {
    on<AnalyzeFoodEvent>(_onAnalyzeFood);
    on<ResetFoodAnalysisEvent>(_onReset);
  }

  Future<void> _onAnalyzeFood(
    AnalyzeFoodEvent event,
    Emitter<FoodAnalysisState> emit,
  ) async {
    emit(const FoodAnalysisLoading());
    try {
      final record = await analyzeFood(event.imageFile);
      emit(FoodAnalysisSuccess(record: record));
    } on Failure catch (f) {
      emit(FoodAnalysisError(message: f.message));
    } catch (e) {
      emit(FoodAnalysisError(message: 'Failed to analyze food: $e'));
    }
  }

  void _onReset(
    ResetFoodAnalysisEvent event,
    Emitter<FoodAnalysisState> emit,
  ) {
    emit(const FoodAnalysisInitial());
  }
}
