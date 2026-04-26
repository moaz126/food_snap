import 'package:flutter/material.dart';
import 'package:food_snap/core/theme/app_palette.dart';

String _formatNumber(double value) {
  if (value == value.truncate()) {
    return value.toInt().toString();
  }
  return value.toString();
}

class CaloriesCard extends StatelessWidget {
  final double calories;
  final String? servingSize;

  const CaloriesCard({
    super.key,
    required this.calories,
    this.servingSize,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.primaryBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ESTIMATED CALORIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: palette.primary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatNumber(calories),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: palette.primary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      servingSize != null ? 'kcal / per serving' : 'kcal',
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Text(
            '🔥',
            style: TextStyle(fontSize: 36),
          ),
        ],
      ),
    );
  }
}
