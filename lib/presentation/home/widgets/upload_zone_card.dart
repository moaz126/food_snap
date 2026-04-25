import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';

class UploadZoneCard extends StatelessWidget {
  final File? selectedImage;
  final bool isLoading;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onRemoveImage;

  const UploadZoneCard({
    super.key,
    required this.selectedImage,
    required this.isLoading,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onRemoveImage,
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

    // STATE 3: Loading
    if (isLoading) {
      return Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Blurred image background
            if (selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Image.file(
                    selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            // Dark overlay
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black45,
              ),
            ),
            // Loading indicator center
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Analyzing your food...',
                    style: AppTextStyles.body
                        .copyWith(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // STATE 2: Image selected
    if (selectedImage != null) {
      return Stack(
        children: [
          // Full image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              selectedImage!,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
            ),
          ),
          // Remove button top right
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onRemoveImage,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // STATE 1: No image (default)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: border,
          width: 2,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera icon in circle
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryBg,
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              color: primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to analyze your food',
            style: AppTextStyles.h3.copyWith(color: textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Camera or gallery',
            style: AppTextStyles.caption.copyWith(color: textSub),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Camera + Gallery buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: onCameraTap,
                filled: true,
                primary: primary,
                textColor: textColor,
                border: border,
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: onGalleryTap,
                filled: false,
                primary: primary,
                textColor: textColor,
                border: border,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final Color primary;
  final Color textColor;
  final Color border;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
    required this.primary,
    required this.textColor,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: textColor),
        label: Text(label, style: TextStyle(color: textColor)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
    }
  }
}
