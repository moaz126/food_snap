import 'package:flutter_test/flutter_test.dart';
import 'package:food_snap/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('formats todays date as Today', () {
      final now = DateTime.now();
      final result = DateFormatter.relative(now);

      expect(result, contains('Today'));
    });

    test('formats yesterdays date as Yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = DateFormatter.relative(yesterday);

      expect(result, contains('Yesterday'));
    });

    test('formats older date with day month format', () {
      final oldDate = DateTime(2026, 1, 15, 10, 30);
      final result = DateFormatter.relative(oldDate);

      expect(result, contains('Jan'));
      expect(result, contains('15'));
    });

    test('includes time in formatted string', () {
      final date = DateTime(2026, 4, 24, 14, 30);
      final result = DateFormatter.relative(date);

      // Time component always contains a colon (e.g. '2:30 PM')
      expect(result, contains(':'));
    });
  });
}
