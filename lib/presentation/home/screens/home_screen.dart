import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/constants/app_colors.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/navigation/app_router.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/presentation/home/bloc/history_cubit.dart';
import 'package:food_snap/presentation/home/widgets/analyze_section.dart';
import 'package:food_snap/presentation/home/widgets/empty_history_state.dart';
import 'package:food_snap/presentation/home/widgets/food_history_tile.dart';
import 'package:food_snap/presentation/home/widgets/home_app_bar.dart';
import 'package:food_snap/presentation/home/widgets/source_picker_sheet.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_bloc.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_event.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_state.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: Remove mock data — replace with BlocBuilder
  // when UI testing is complete
  final List<FoodRecord> mockRecords = [
    FoodRecord(
      id: '1',
      imageUri: '',
      detectedFoodName: 'Margherita Pizza',
      cuisineTags: ['Italian', 'Vegetarian'],
      confidencePercent: 94.0,
      nutrition: NutritionInfo(
        calories: 285,
        protein: 9,
        carbs: 36,
        fat: 10,
        fiber: 2,
        sugar: 4,
        sodium: 520,
        servingSize: '1 slice',
      ),
      rawApiSummary: '',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    FoodRecord(
      id: '2',
      imageUri: '',
      detectedFoodName: 'Caesar Salad',
      cuisineTags: ['American'],
      confidencePercent: 88.0,
      nutrition: NutritionInfo(
        calories: 180,
        protein: 6,
        carbs: 14,
        fat: 12,
        fiber: 3,
        sugar: 2,
        sodium: 380,
        servingSize: '1 bowl',
      ),
      rawApiSummary: '',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FoodRecord(
      id: '3',
      imageUri: '',
      detectedFoodName: 'Chicken Biryani',
      cuisineTags: ['Pakistani', 'South Asian'],
      confidencePercent: 96.0,
      nutrition: NutritionInfo(
        calories: 490,
        protein: 28,
        carbs: 58,
        fat: 14,
        fiber: 4,
        sugar: 3,
        sodium: 720,
        servingSize: '1 plate',
      ),
      rawApiSummary: '',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    FoodRecord(
      id: '4',
      imageUri: '',
      detectedFoodName: 'Banana',
      cuisineTags: ['Fruit'],
      confidencePercent: 99.0,
      nutrition: NutritionInfo(
        calories: 89,
        protein: 1,
        carbs: 23,
        fat: 0,
        fiber: 3,
        sugar: 12,
        sodium: 1,
        servingSize: '1 medium',
      ),
      rawApiSummary: '',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    FoodRecord(
      id: '5',
      imageUri: '',
      detectedFoodName: 'Avocado Toast',
      cuisineTags: ['American', 'Healthy'],
      confidencePercent: 91.0,
      nutrition: NutritionInfo(
        calories: 320,
        protein: 8,
        carbs: 30,
        fat: 18,
        fiber: 7,
        sugar: 2,
        sodium: 420,
        servingSize: '2 slices',
      ),
      rawApiSummary: '',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FoodRecord(
      id: '6',
      imageUri: '',
      detectedFoodName: 'Chocolate Brownie',
      cuisineTags: ['Dessert', 'American'],
      confidencePercent: 87.0,
      nutrition: NutritionInfo(
        calories: 410,
        protein: 5,
        carbs: 52,
        fat: 20,
        fiber: 2,
        sugar: 38,
        sodium: 180,
        servingSize: '1 piece',
      ),
      rawApiSummary: '',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FoodRecord(
      id: '7',
      imageUri: '',
      detectedFoodName: 'Green Smoothie',
      cuisineTags: ['Healthy', 'Vegan'],
      confidencePercent: 82.0,
      nutrition: NutritionInfo(
        calories: 145,
        protein: 4,
        carbs: 28,
        fat: 2,
        fiber: 5,
        sugar: 18,
        sodium: 90,
        servingSize: '1 glass',
      ),
      rawApiSummary: '',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FoodRecord(
      id: '8',
      imageUri: '',
      detectedFoodName: 'Beef Burger',
      cuisineTags: ['American', 'Fast Food'],
      confidencePercent: 93.0,
      nutrition: NutritionInfo(
        calories: 650,
        protein: 35,
        carbs: 48,
        fat: 32,
        fiber: 2,
        sugar: 8,
        sodium: 980,
        servingSize: '1 burger',
      ),
      rawApiSummary: '',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    FoodRecord(
      id: '9',
      imageUri: '',
      detectedFoodName: 'Dal Chawal',
      cuisineTags: ['Pakistani', 'Vegetarian'],
      confidencePercent: 90.0,
      nutrition: NutritionInfo(
        calories: 380,
        protein: 14,
        carbs: 65,
        fat: 6,
        fiber: 8,
        sugar: 3,
        sodium: 540,
        servingSize: '1 plate',
      ),
      rawApiSummary: '',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    FoodRecord(
      id: '10',
      imageUri: '',
      detectedFoodName: 'Strawberry Cheesecake',
      cuisineTags: ['Dessert', 'American'],
      confidencePercent: 85.0,
      nutrition: NutritionInfo(
        calories: 520,
        protein: 8,
        carbs: 45,
        fat: 34,
        fiber: 1,
        sugar: 36,
        sodium: 290,
        servingSize: '1 slice',
      ),
      rawApiSummary: '',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    FoodRecord(
      id: '11',
      imageUri: '',
      detectedFoodName: 'Chicken Karahi',
      cuisineTags: ['Pakistani'],
      confidencePercent: 95.0,
      nutrition: NutritionInfo(
        calories: 420,
        protein: 32,
        carbs: 12,
        fat: 26,
        fiber: 2,
        sugar: 4,
        sodium: 680,
        servingSize: '1 serving',
      ),
      rawApiSummary: '',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    FoodRecord(
      id: '12',
      imageUri: '',
      detectedFoodName: 'Mango',
      cuisineTags: ['Fruit', 'Pakistani'],
      confidencePercent: 98.0,
      nutrition: NutritionInfo(
        calories: 99,
        protein: 1,
        carbs: 25,
        fat: 0,
        fiber: 3,
        sugar: 23,
        sodium: 2,
        servingSize: '1 medium',
      ),
      rawApiSummary: '',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  final ImagePicker _picker = ImagePicker();
  late final ScrollController _scrollController;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().load();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showFab) {
        setState(() => _showFab = true);
      } else if (_scrollController.offset <= 300 && _showFab) {
        setState(() => _showFab = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked == null || !mounted) return;

      context.read<FoodAnalysisBloc>().add(
            AnalyzeFoodEvent(imageFile: File(picked.path)),
          );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permission denied or failed to pick image'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _pickAndAnalyze(source),
          ),
        ),
      );
    }
  }

  void _showSourcePicker() {
    showSourcePickerSheet(context, _pickAndAnalyze);
  }

  void _openResult(FoodRecord record) {
    context.pushNamed(AppRoutes.result, extra: record);
  }

  void _onAnalysisStateChanged(BuildContext context, FoodAnalysisState state) {
    if (state is FoodAnalysisError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _showSourcePicker,
          ),
        ),
      );
    }
    if (state is FoodAnalysisSuccess) {
      context.read<HistoryCubit>().load();
      _openResult(state.record);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final primaryBg =
        isDark ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    final count = mockRecords.length;

    return BlocListener<FoodAnalysisBloc, FoodAnalysisState>(
      listener: _onAnalysisStateChanged,
      child: Scaffold(
        appBar: const HomeAppBar(),
        floatingActionButton: AnimatedScale(
          scale: _showFab ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
            },
            child: const Icon(Icons.keyboard_arrow_up),
          ),
        ),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnalyzeSection(
                      onCamera: () => _pickAndAnalyze(ImageSource.camera),
                      onGallery: () => _pickAndAnalyze(ImageSource.gallery),
                      onAnalyze: _showSourcePicker,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Text(
                          'Recent Scans',
                          style: AppTextStyles.h3.copyWith(color: textColor),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$count',
                              style: AppTextStyles.caption
                                  .copyWith(color: primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            if (mockRecords.isEmpty)
              const SliverToBoxAdapter(child: EmptyHistoryState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final record = mockRecords[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FoodHistoryTile(
                          record: record,
                          onTap: () => _openResult(record),
                        ),
                      );
                    },
                    childCount: mockRecords.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
