import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';

class UploadZoneCard extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final bool isLoading;

  const UploadZoneCard({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final primary = palette.primary;
    final primaryBg = palette.primaryBg;
    final surface = palette.surface;
    final border = palette.border;
    final textColor = palette.text;
    final textSub = palette.textSub;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primaryBg,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.camera_alt_rounded, size: 36, color: primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to analyze your food',
            style: AppTextStyles.h3.copyWith(color: textColor),
            textAlign: TextAlign.center,
          ),
          if (isLoading) ...[
            const SizedBox(height: 20),
            LinearProgressIndicator(
              color: primary,
              backgroundColor: primaryBg,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyzing image…',
              style: AppTextStyles.caption.copyWith(color: primary),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              'Camera or gallery',
              style: AppTextStyles.caption.copyWith(color: textSub),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCamera,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: AppTextStyles.label,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onGallery,
                    icon: Icon(Icons.photo_library_outlined,
                        size: 18, color: textColor),
                    label: Text('Gallery', style: TextStyle(color: textColor)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: AppTextStyles.label,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
