import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';
import 'package:food_snap/core/utils/image_storage_service.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/presentation/result_detail/widgets/calories_card.dart';
import 'package:food_snap/presentation/result_detail/widgets/confidence_badge.dart';
import 'package:food_snap/presentation/result_detail/widgets/cuisine_tag.dart';
import 'package:food_snap/presentation/result_detail/widgets/full_screen_image_viewer.dart';
import 'package:food_snap/presentation/result_detail/widgets/macro_item.dart';
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
  static const double _collapseOffset = 240;

  late final ScrollController _scrollController;
  bool _isCollapsed = false;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  String _formatNumber(double value) {
    if (value == value.truncate()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  void _handleScroll() {
    final shouldCollapse = _scrollController.offset > _collapseOffset;
    if (shouldCollapse != _isCollapsed) {
      setState(() => _isCollapsed = shouldCollapse);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void _openFullscreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => FullScreenImageViewer(
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
    final palette = context.appPalette;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildHeaderAppBar(record, surfaceColor, palette),
          _buildBodyContent(record, palette),
        ],
      ),
    );
  }

  // ── Section builders ─────────────────────────────────────────────────────

  SliverAppBar _buildHeaderAppBar(
    FoodRecord record,
    Color surfaceColor,
    AppPalette palette,
  ) {
    return SliverAppBar(
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
            color: _isCollapsed ? palette.primary : Colors.white,
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
        background: _buildFoodImage(record),
      ),
    );
  }

  SliverToBoxAdapter _buildBodyContent(FoodRecord record, AppPalette palette) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildFoodInfoCard(record, palette),
            const SizedBox(height: 16),
            _buildCaloriesSection(record),
            const SizedBox(height: 16),
            _buildMacrosSection(record, palette),
            const SizedBox(height: 16),
            _buildNutritionDetails(record, palette),
            const SizedBox(height: 16),
            _buildDisclaimer(palette),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodImage(FoodRecord record) {
    return FutureBuilder<bool>(
      future: ImageStorageService.imageExists(record.imageUri),
      builder: (context, snapshot) {
        final exists = snapshot.data ?? false;
        final imageWidget = exists && record.imageUri.isNotEmpty
            ? Hero(
                tag: 'food_image_${record.id}',
                child: Image.file(
                  File(record.imageUri),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _buildImagePlaceholder(context.appPalette),
                ),
              )
            : Hero(
                tag: 'food_image_${record.id}',
                child: _buildImagePlaceholder(context.appPalette),
              );

        return Stack(
          fit: StackFit.expand,
          children: [
            imageWidget,
            Positioned(
              bottom: 12,
              right: 12,
              child: _buildFullscreenButton(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePlaceholder(AppPalette palette) {
    return Container(
      color: palette.amberBg,
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

  Widget _buildFoodInfoCard(FoodRecord record, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
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
              ConfidenceBadge(percent: record.confidencePercent),
            ],
          ),
          if (record.cuisineTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: record.cuisineTags
                  .map((tag) => CuisineTag(tag: tag))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCaloriesSection(FoodRecord record) {
    return CaloriesCard(
      calories: record.nutrition.calories,
      servingSize: record.nutrition.servingSize,
    );
  }

  Widget _buildMacrosSection(FoodRecord record, AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MACRONUTRIENTS',
          style: AppTextStyles.caption.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: palette.textSub,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MacroItem(
                label: 'Protein',
                value: record.nutrition.protein,
                unit: 'g',
                color: palette.primary,
                bgColor: palette.primaryBg,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MacroItem(
                label: 'Carbs',
                value: record.nutrition.carbs,
                unit: 'g',
                color: palette.amber,
                bgColor: palette.amberBg,
                maxReference: 300,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MacroItem(
                label: 'Fat',
                value: record.nutrition.fat,
                unit: 'g',
                color: palette.coral,
                bgColor: palette.coralBg,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionDetails(FoodRecord record, AppPalette palette) {
    final rows = <Widget>[];

    if (record.nutrition.fiber != null) {
      rows.add(NutritionDetailRow(
        title: 'Fiber',
        value: '${_formatNumber(record.nutrition.fiber!)}g',
      ));
    }
    if (record.nutrition.sugar != null) {
      rows.add(NutritionDetailRow(
        title: 'Sugar',
        value: '${_formatNumber(record.nutrition.sugar!)}g',
      ));
    }
    if (record.nutrition.sodium != null) {
      rows.add(NutritionDetailRow(
        title: 'Sodium',
        value: '${_formatNumber(record.nutrition.sodium!)}mg',
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
            color: palette.textSub,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildDisclaimer(AppPalette palette) {
    return Container(
      decoration: BoxDecoration(
        color: palette.amberBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: palette.amber, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: palette.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nutrition values are AI estimates only — '
              'not a substitute for medical or dietary advice.',
              style: AppTextStyles.caption.copyWith(color: palette.textSub),
            ),
          ),
        ],
      ),
    );
  }
}
