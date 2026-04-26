import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';
import 'package:food_snap/presentation/home/bloc/history_cubit.dart';
import 'package:food_snap/presentation/home/bloc/history_state.dart';

class HistorySectionHeader extends StatelessWidget {
  final VoidCallback onDeleteAllTap;

  const HistorySectionHeader({
    super.key,
    required this.onDeleteAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Row(
      children: [
        Text(
          'Recent Scans',
          style: AppTextStyles.h3.copyWith(color: palette.text),
        ),
        const SizedBox(width: 8),
        BlocBuilder<HistoryCubit, HistoryState>(
          buildWhen: (prev, curr) {
            final prevCount =
                prev is HistoryLoaded ? prev.records.length : null;
            final currCount =
                curr is HistoryLoaded ? curr.records.length : null;
            return prevCount != currCount;
          },
          builder: (context, state) {
            if (state is HistoryLoaded && state.records.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: palette.primaryBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${state.records.length}',
                  style: AppTextStyles.caption.copyWith(color: palette.primary),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const Spacer(),
        BlocBuilder<HistoryCubit, HistoryState>(
          buildWhen: (prev, curr) =>
              (prev is HistoryLoaded) != (curr is HistoryLoaded),
          builder: (context, state) {
            if (state is! HistoryLoaded || state.records.isEmpty) {
              return const SizedBox.shrink();
            }
            return TextButton.icon(
              onPressed: onDeleteAllTap,
              style: TextButton.styleFrom(
                foregroundColor: palette.coral,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: Text(
                'Delete All',
                style: AppTextStyles.caption.copyWith(color: palette.coral),
              ),
            );
          },
        ),
      ],
    );
  }
}
