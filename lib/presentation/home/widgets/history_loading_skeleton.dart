import 'package:flutter/material.dart';
import 'package:food_snap/core/theme/app_palette.dart';

class HistoryLoadingSkeleton extends StatefulWidget {
  const HistoryLoadingSkeleton({super.key});

  @override
  State<HistoryLoadingSkeleton> createState() => _HistoryLoadingSkeletonState();
}

class _HistoryLoadingSkeletonState extends State<HistoryLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final opacity = 0.3 + (_shimmerController.value * 0.4);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildSkeletonTile(palette, opacity),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonTile(AppPalette palette, double opacity) {
    final shimmerColor = palette.surface2.withValues(alpha: opacity);
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Thumbnail placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name placeholder
              Container(
                width: 140,
                height: 14,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              // Timestamp placeholder
              Container(
                width: 90,
                height: 12,
                decoration: BoxDecoration(
                  color: palette.surface2.withValues(alpha: opacity * 0.75),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
