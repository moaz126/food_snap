import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_snap/data/ai/ai_provider.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_bloc.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_event.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_state.dart';

import '../../helpers/mock_classes.dart';

void main() {
  setUpAll(registerFallbacks);

  group('FoodAnalysisBloc', () {
    late FoodAnalysisBloc bloc;
    late MockAnalyzeFood mockAnalyzeFood;

    final testRecord = FoodRecord(
      id: 'test-123',
      imageUri: '/test/image.jpg',
      detectedFoodName: 'Pizza',
      cuisineTags: const ['Italian'],
      confidencePercent: 90.0,
      nutrition: const NutritionInfo(
        calories: 285,
        protein: 9,
        carbs: 36,
        fat: 10,
      ),
      rawApiSummary: 'Pizza slice',
      createdAt: DateTime(2026, 4, 24),
    );

    final testImageFile = File('test/assets/test_food.jpg');

    setUp(() {
      mockAnalyzeFood = MockAnalyzeFood();
      bloc = FoodAnalysisBloc(analyzeFood: mockAnalyzeFood);
    });

    tearDown(() => bloc.close());

    test('initial state is FoodAnalysisInitial', () {
      expect(bloc.state, isA<FoodAnalysisInitial>());
    });

    blocTest<FoodAnalysisBloc, FoodAnalysisState>(
      'emits [Loading, Success] when analysis succeeds',
      build: () {
        when(() => mockAnalyzeFood(testImageFile))
            .thenAnswer((_) async => testRecord);
        return FoodAnalysisBloc(analyzeFood: mockAnalyzeFood);
      },
      act: (bloc) => bloc.add(AnalyzeFoodEvent(testImageFile)),
      expect: () => [
        isA<FoodAnalysisLoading>(),
        isA<FoodAnalysisSuccess>(),
      ],
      verify: (_) {
        verify(() => mockAnalyzeFood(testImageFile)).called(1);
      },
    );

    blocTest<FoodAnalysisBloc, FoodAnalysisState>(
      'emits [Loading, Error] on noInternet exception',
      build: () {
        when(() => mockAnalyzeFood(testImageFile)).thenThrow(
          const AiProviderException(
            message: 'No internet',
            type: AiProviderErrorType.noInternet,
          ),
        );
        return FoodAnalysisBloc(analyzeFood: mockAnalyzeFood);
      },
      act: (bloc) => bloc.add(AnalyzeFoodEvent(testImageFile)),
      expect: () => [
        isA<FoodAnalysisLoading>(),
        isA<FoodAnalysisError>(),
      ],
      verify: (bloc) {
        final errorState = bloc.state as FoodAnalysisError;
        expect(errorState.errorType, FoodAnalysisErrorType.noInternet);
      },
    );

    blocTest<FoodAnalysisBloc, FoodAnalysisState>(
      'emits [Loading, Error] on timeout exception',
      build: () {
        when(() => mockAnalyzeFood(testImageFile)).thenThrow(
          const AiProviderException(
            message: 'Timeout',
            type: AiProviderErrorType.timeout,
          ),
        );
        return FoodAnalysisBloc(analyzeFood: mockAnalyzeFood);
      },
      act: (bloc) => bloc.add(AnalyzeFoodEvent(testImageFile)),
      expect: () => [
        isA<FoodAnalysisLoading>(),
        isA<FoodAnalysisError>(),
      ],
    );

    blocTest<FoodAnalysisBloc, FoodAnalysisState>(
      'emits [Initial] on ResetAnalysisEvent',
      build: () => FoodAnalysisBloc(analyzeFood: mockAnalyzeFood),
      act: (bloc) => bloc.add(const ResetAnalysisEvent()),
      expect: () => [isA<FoodAnalysisInitial>()],
    );

    test('success state contains correct record', () async {
      when(() => mockAnalyzeFood(testImageFile))
          .thenAnswer((_) async => testRecord);

      bloc.add(AnalyzeFoodEvent(testImageFile));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<FoodAnalysisLoading>(),
          isA<FoodAnalysisSuccess>(),
        ]),
      );

      final success = bloc.state as FoodAnalysisSuccess;
      expect(success.record.detectedFoodName, 'Pizza');
      expect(success.record.nutrition.calories, 285);
    });
  });
}
