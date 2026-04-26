import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_snap/core/errors/failures.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/presentation/home/bloc/history_cubit.dart';
import 'package:food_snap/presentation/home/bloc/history_state.dart';

import '../../helpers/mock_classes.dart';

void main() {
  group('HistoryCubit', () {
    late HistoryCubit cubit;
    late MockGetAllRecords mockGetAllRecords;

    final testRecords = [
      FoodRecord(
        id: '1',
        imageUri: '/test/image1.jpg',
        detectedFoodName: 'Pizza',
        cuisineTags: const ['Italian'],
        confidencePercent: 90.0,
        nutrition: const NutritionInfo(
          calories: 285,
          protein: 9,
          carbs: 36,
          fat: 10,
        ),
        rawApiSummary: '',
        createdAt: DateTime(2026, 4, 24),
      ),
      FoodRecord(
        id: '2',
        imageUri: '/test/image2.jpg',
        detectedFoodName: 'Salad',
        cuisineTags: const ['Healthy'],
        confidencePercent: 85.0,
        nutrition: const NutritionInfo(
          calories: 180,
          protein: 6,
          carbs: 14,
          fat: 12,
        ),
        rawApiSummary: '',
        createdAt: DateTime(2026, 4, 23),
      ),
    ];

    setUp(() {
      mockGetAllRecords = MockGetAllRecords();
      cubit = HistoryCubit(getAllRecords: mockGetAllRecords);
    });

    tearDown(() => cubit.close());

    test('initial state is HistoryInitial', () {
      expect(cubit.state, isA<HistoryInitial>());
    });

    blocTest<HistoryCubit, HistoryState>(
      'emits [Loading, Loaded] when records exist',
      build: () {
        when(() => mockGetAllRecords()).thenAnswer((_) async => testRecords);
        return HistoryCubit(getAllRecords: mockGetAllRecords);
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        isA<HistoryLoading>(),
        isA<HistoryLoaded>(),
      ],
      verify: (_) {
        verify(() => mockGetAllRecords()).called(1);
      },
    );

    blocTest<HistoryCubit, HistoryState>(
      'emits [Loading, Empty] when no records',
      build: () {
        when(() => mockGetAllRecords()).thenAnswer((_) async => []);
        return HistoryCubit(getAllRecords: mockGetAllRecords);
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        isA<HistoryLoading>(),
        isA<HistoryEmpty>(),
      ],
    );

    blocTest<HistoryCubit, HistoryState>(
      'emits [Loading, Error] when exception thrown',
      build: () {
        when(() => mockGetAllRecords()).thenThrow(
          const DatabaseException(message: 'DB failed'),
        );
        return HistoryCubit(getAllRecords: mockGetAllRecords);
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        isA<HistoryLoading>(),
        isA<HistoryError>(),
      ],
    );

    blocTest<HistoryCubit, HistoryState>(
      'loaded state contains correct records count',
      build: () {
        when(() => mockGetAllRecords()).thenAnswer((_) async => testRecords);
        return HistoryCubit(getAllRecords: mockGetAllRecords);
      },
      act: (cubit) => cubit.loadHistory(),
      verify: (cubit) {
        final state = cubit.state as HistoryLoaded;
        expect(state.records.length, 2);
        expect(state.records.first.detectedFoodName, 'Pizza');
      },
    );
  });
}
