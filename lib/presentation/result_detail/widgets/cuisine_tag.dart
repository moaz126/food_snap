import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';

class CuisineTag extends StatelessWidget {
  final String tag;

  const CuisineTag({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final bgColor = palette.surface2;
    final textColor = palette.textSub;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: AppTextStyles.caption.copyWith(color: textColor),
      ),
    );
  }
}
