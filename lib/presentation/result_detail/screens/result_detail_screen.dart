import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_colors.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/presentation/result_detail/widgets/calories_card.dart';
import 'package:food_snap/presentation/result_detail/widgets/nutrition_detail_row.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ResultDetailScreen
// ─────────────────────────────────────────────────────────────────────────────

class ResultDetailScreen extends StatefulWidget {
  final FoodRecord record;

  const ResultDetailScreen({super.key, required this.record});

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  late final ScrollController _scrollController;
  bool _isCollapsed = false;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 240 && !_isCollapsed) {
      setState(() => _isCollapsed = true);
    } else if (_scrollController.offset <= 240 && _isCollapsed) {
      setState(() => _isCollapsed = false);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  // ── Color helpers ────────────────────────────────────────────────────────

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _primary =>
      _isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
  Color get _primaryBg =>
      _isDark ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
  Color get _amber => _isDark ? AppColors.darkAmber : AppColors.lightAmber;
  Color get _amberBg =>
      _isDark ? AppColors.darkAmberBg : AppColors.lightAmberBg;
  Color get _coral => _isDark ? AppColors.darkCoral : AppColors.lightCoral;
  Color get _coralBg =>
      _isDark ? AppColors.darkCoralBg : AppColors.lightCoralBg;
  Color get _textSub =>
      _isDark ? AppColors.darkTextSub : AppColors.lightTextSub;
  Color get _border => _isDark ? AppColors.darkBorder : AppColors.lightBorder;

  // ── Actions ──────────────────────────────────────────────────────────────

  void _openFullscreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _FullScreenImageViewer(
          imageUri: widget.record.imageUri,
          heroTag: 'food_image_${widget.record.id}',
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: _isCollapsed ? surfaceColor : Colors.transparent,
            leading: IconButton(
              onPressed: context.pop,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  key: ValueKey(_isCollapsed),
                  color: _isCollapsed ? _primary : Colors.white,
                ),
              ),
            ),
            centerTitle: false,
            titleSpacing: 0,
            title: AnimatedOpacity(
              opacity: _isCollapsed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                record.detectedFoodName,
                style: AppTextStyles.h3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _buildFoodImage(record, surfaceColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildFoodInfoCard(record),
                  const SizedBox(height: 16),
                  _buildCaloriesSection(record),
                  const SizedBox(height: 16),
                  _buildMacrosSection(record),
                  const SizedBox(height: 16),
                  _buildNutritionDetails(record),
                  const SizedBox(height: 16),
                  _buildDisclaimer(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section builders ─────────────────────────────────────────────────────

  Widget _buildFoodImage(FoodRecord record, Color surfaceColor) {
    final Widget imageWidget;
    if (record.imageUri.isNotEmpty) {
      imageWidget = Hero(
        tag: 'food_image_${record.id}',
        child: Image.file(
          File(record.imageUri),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        ),
      );
    } else {
      imageWidget = Hero(
        tag: 'food_image_${record.id}',
        child: _buildImagePlaceholder(),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        // Positioned(
        //   bottom: 0,
        //   left: 0,
        //   right: 0,
        //   child: Container(
        //     height: 100,
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter,
        //         colors: [Colors.transparent, surfaceColor],
        //       ),
        //     ),
        //   ),
        // ),
        Positioned(
          bottom: 12,
          right: 12,
          child: _buildFullscreenButton(),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: _amberBg,
      child: const Center(
        child: Icon(Icons.restaurant, size: 80),
      ),
    );
  }

  Widget _buildFullscreenButton() {
    return GestureDetector(
      onTap: _openFullscreen,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.fullscreen, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildFoodInfoCard(FoodRecord record) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  record.detectedFoodName,
                  style: AppTextStyles.h1.copyWith(fontSize: 24),
                ),
              ),
              const SizedBox(width: 8),
              _ConfidenceBadge(percent: record.confidencePercent),
            ],
          ),
          if (record.cuisineTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: record.cuisineTags
                  .map((tag) => _CuisineTag(tag: tag))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCaloriesSection(FoodRecord record) {
    return CaloriesCard(calories: record.nutrition.calories);
  }

  Widget _buildMacrosSection(FoodRecord record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MACRONUTRIENTS',
          style: AppTextStyles.caption.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: _textSub,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MacroItem(
                label: 'Protein',
                value: record.nutrition.protein,
                unit: 'g',
                color: _primary,
                bgColor: _primaryBg,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MacroItem(
                label: 'Carbs',
                value: record.nutrition.carbs,
                unit: 'g',
                color: _amber,
                bgColor: _amberBg,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MacroItem(
                label: 'Fat',
                value: record.nutrition.fat,
                unit: 'g',
                color: _coral,
                bgColor: _coralBg,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionDetails(FoodRecord record) {
    final rows = <Widget>[];

    if (record.nutrition.fiber != null) {
      rows.add(NutritionDetailRow(
        title: 'Fiber',
        value: '${record.nutrition.fiber!.toStringAsFixed(1)}g',
      ));
    }
    if (record.nutrition.sugar != null) {
      rows.add(NutritionDetailRow(
        title: 'Sugar',
        value: '${record.nutrition.sugar!.toStringAsFixed(1)}g',
      ));
    }
    if (record.nutrition.sodium != null) {
      rows.add(NutritionDetailRow(
        title: 'Sodium',
        value: '${record.nutrition.sodium!.toStringAsFixed(1)}mg',
      ));
    }
    if (record.nutrition.servingSize != null) {
      rows.add(NutritionDetailRow(
        title: 'Serving size',
        value: record.nutrition.servingSize!,
      ));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MORE DETAILS',
          style: AppTextStyles.caption.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: _textSub,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      decoration: BoxDecoration(
        color: _amberBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _amber, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: _amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nutrition values are AI estimates only — '
              'not a substitute for medical or dietary advice.',
              style: AppTextStyles.caption.copyWith(color: _textSub),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FullScreenImageViewer
// ─────────────────────────────────────────────────────────────────────────────

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUri;
  final String heroTag;

  const _FullScreenImageViewer({
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
                onTap:
                    () {}, // absorb taps on the image (prevent barrier close)
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
        color: Colors.grey[800],
        child: const Icon(Icons.restaurant, size: 80, color: Colors.white54),
      );
    }
    try {
      return Image.file(
        File(imageUri),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[800],
          child: const Icon(Icons.image_not_supported,
              size: 80, color: Colors.white54),
        ),
      );
    } catch (_) {
      return Container(
        color: Colors.grey[800],
        child: const Icon(Icons.image_not_supported,
            size: 80, color: Colors.white54),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ConfidenceBadge
// ─────────────────────────────────────────────────────────────────────────────

class _ConfidenceBadge extends StatelessWidget {
  final double percent;

  const _ConfidenceBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor;
    final Color textColor;
    final IconData icon;

    if (percent >= 90) {
      bgColor = isDark ? AppColors.darkGreenBg : AppColors.lightGreenBg;
      textColor = isDark ? AppColors.darkGreen : AppColors.lightGreen;
      icon = Icons.check_circle;
    } else if (percent >= 70) {
      bgColor = isDark ? AppColors.darkAmberBg : AppColors.lightAmberBg;
      textColor = isDark ? AppColors.darkAmber : AppColors.lightAmber;
      icon = Icons.info;
    } else {
      bgColor = isDark ? AppColors.darkCoralBg : AppColors.lightCoralBg;
      textColor = isDark ? AppColors.darkCoral : AppColors.lightCoral;
      icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 14),
          const SizedBox(width: 4),
          Text(
            '${percent.toInt()}% match',
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CuisineTag
// ─────────────────────────────────────────────────────────────────────────────

class _CuisineTag extends StatelessWidget {
  final String tag;

  const _CuisineTag({required this.tag});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface2 : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: AppTextStyles.caption.copyWith(color: textColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MacroItem
// ─────────────────────────────────────────────────────────────────────────────

class _MacroItem extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final Color bgColor;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: AppTextStyles.h3.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
