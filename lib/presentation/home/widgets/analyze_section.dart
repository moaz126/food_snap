import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';
import 'package:food_snap/presentation/home/widgets/upload_zone_card.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_bloc.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_state.dart';

class AnalyzeSection extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onRemoveImage;
  final VoidCallback onAnalyze;

  const AnalyzeSection({
    super.key,
    required this.selectedImage,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onRemoveImage,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final primary = palette.primary;

    return BlocBuilder<FoodAnalysisBloc, FoodAnalysisState>(
      builder: (context, state) {
        final isLoading = state is FoodAnalysisLoading;
        final canAnalyze = selectedImage != null;

        return Column(
          children: [
            UploadZoneCard(
              selectedImage: selectedImage,
              isLoading: isLoading,
              onCameraTap: onCameraTap,
              onGalleryTap: onGalleryTap,
              onRemoveImage: onRemoveImage,
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canAnalyze && !isLoading ? onAnalyze : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  disabledBackgroundColor: primary.withValues(alpha: 0.4),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
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
