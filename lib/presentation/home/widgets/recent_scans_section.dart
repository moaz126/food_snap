import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/presentation/home/bloc/history_cubit.dart';
import 'package:food_snap/presentation/home/bloc/history_state.dart';
import 'package:food_snap/presentation/home/widgets/empty_history_state.dart';
import 'package:food_snap/presentation/home/widgets/food_history_tile.dart';

class RecentScansSection extends StatelessWidget {
  final void Function(FoodRecord) onTap;

  const RecentScansSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final primary = palette.primary;
    final textColor = palette.text;
    final primaryBg = palette.primaryBg;

    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        final count = state is HistoryLoaded ? state.records.length : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Scans',
                  style: AppTextStyles.h3.copyWith(color: textColor),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count',
                      style: AppTextStyles.caption.copyWith(color: primary),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            _HistoryContent(state: state, onTap: onTap),
          ],
        );
      },
    );
  }
}

class _HistoryContent extends StatelessWidget {
  final HistoryState state;
  final void Function(FoodRecord) onTap;

  const _HistoryContent({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textSub = context.appPalette.textSub;

    if (state is HistoryLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is HistoryError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (state as HistoryError).message,
            style: AppTextStyles.body.copyWith(color: textSub),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.read<HistoryCubit>().load(),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (state is HistoryEmpty || state is HistoryInitial) {
      return const EmptyHistoryState();
    }

    final records = (state as HistoryLoaded).records;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FoodHistoryTile(
            record: record,
            onTap: () => onTap(record),
          ),
        );
      },
    );
  }
}
