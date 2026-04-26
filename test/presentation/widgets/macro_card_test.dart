import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/presentation/result_detail/widgets/macro_card.dart';

void main() {
  group('MacroCard Widget', () {
    testWidgets('displays macro labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MacroCard(
              nutrition: NutritionInfo(
                calories: 300,
                protein: 9,
                carbs: 36,
                fat: 10,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
    });

    testWidgets('displays protein value correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MacroCard(
              nutrition: NutritionInfo(
                calories: 300,
                protein: 9,
                carbs: 36,
                fat: 10,
              ),
            ),
          ),
        ),
      );

      // MacroCard formats values with toStringAsFixed(1) + ' g'
      expect(find.text('9.0 g'), findsOneWidget);
    });

    testWidgets('displays decimal value correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MacroCard(
              nutrition: NutritionInfo(
                calories: 300,
                protein: 10,
                carbs: 30,
                fat: 10.5,
              ),
            ),
          ),
        ),
      );

      expect(find.text('10.5 g'), findsOneWidget);
    });

    testWidgets('displays Macros heading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MacroCard(
              nutrition: NutritionInfo(
                calories: 300,
                protein: 9,
                carbs: 36,
                fat: 10,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Macros'), findsOneWidget);
    });
  });
}
