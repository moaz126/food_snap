import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_colors.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Analyze Food', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Capture or pick a food image to estimate nutrition details.',
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Analyzing image...',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.lightPrimary),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCamera,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
