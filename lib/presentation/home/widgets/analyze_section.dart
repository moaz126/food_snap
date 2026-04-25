import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';
import 'package:food_snap/presentation/home/widgets/upload_zone_card.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_bloc.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_state.dart';

class AnalyzeSection extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onAnalyze;

  const AnalyzeSection({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final primary = palette.primary;

    return BlocBuilder<FoodAnalysisBloc, FoodAnalysisState>(
      builder: (context, state) {
        final isLoading = state is FoodAnalysisLoading;

        return Column(
          children: [
            UploadZoneCard(
              onCamera: onCamera,
              onGallery: onGallery,
              isLoading: isLoading,
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onAnalyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  disabledBackgroundColor: primary.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Analyze Food',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
