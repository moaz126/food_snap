import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_colors.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUri;
  final String heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUri,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: GestureDetector(
                onTap: () {},
                child: Hero(
                  tag: heroTag,
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: _buildImage(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUri.isEmpty) {
      return Container(
        color: AppColors.darkSurface2,
        child: const Icon(Icons.restaurant, size: 80, color: Colors.white54),
      );
    }

    try {
      return Image.file(
        File(imageUri),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.darkSurface2,
          child: const Icon(
            Icons.image_not_supported,
            size: 80,
            color: Colors.white54,
          ),
        ),
      );
    } catch (_) {
      return Container(
        color: AppColors.darkSurface2,
        child: const Icon(
          Icons.image_not_supported,
          size: 80,
          color: Colors.white54,
        ),
      );
    }
  }
}
