import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_colors.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';

void showSourcePickerSheet(
  BuildContext context,
  void Function(ImageSource) onSourceSelected,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
      final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      final textColor = isDark ? AppColors.darkText : AppColors.lightText;
      final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

      return Material(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select source',
                  style: AppTextStyles.h3.copyWith(color: textColor),
                ),
                const SizedBox(height: 16),
                _SourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  primary: primary,
                  textColor: textColor,
                  border: border,
                  onTap: () {
                    Navigator.pop(ctx);
                    onSourceSelected(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 12),
                _SourceOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Photo Library',
                  primary: primary,
                  textColor: textColor,
                  border: border,
                  onTap: () {
                    Navigator.pop(ctx);
                    onSourceSelected(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color primary;
  final Color textColor;
  final Color border;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.primary,
    required this.textColor,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(icon, color: primary, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.label.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
