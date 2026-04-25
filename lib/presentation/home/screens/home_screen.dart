import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/navigation/app_router.dart';
import 'package:food_snap/core/theme/app_palette.dart';
import 'package:food_snap/core/utils/image_picker_service.dart';
import 'package:food_snap/core/utils/permission_handler_helper.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/presentation/home/bloc/history_cubit.dart';
import 'package:food_snap/presentation/home/widgets/empty_history_state.dart';
import 'package:food_snap/presentation/home/widgets/food_history_tile.dart';
import 'package:food_snap/presentation/home/widgets/home_app_bar.dart';
import 'package:food_snap/presentation/home/widgets/upload_zone_card.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_bloc.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_event.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_state.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  late final ScrollController _scrollController;
  late final ImagePickerService _imagePickerService;
  bool _showFab = false;

  // Mock data for UI testing
  final List<FoodRecord> mockRecords = [];

  bool get _canAnalyze => _selectedImage != null;

  @override
  void initState() {
    super.initState();
    _imagePickerService = ImagePickerService();
    context.read<HistoryCubit>().load();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 300 && !_showFab) {
      setState(() => _showFab = true);
    } else if (_scrollController.offset <= 300 && _showFab) {
      setState(() => _showFab = false);
    }
  }

  Future<void> _handleImageSource(ImageSource source) async {
    final permission = source == ImageSource.camera
        ? PermissionHandlerHelper.requestCamera
        : PermissionHandlerHelper.requestPhotos;

    final status = await permission();

    if (!mounted) return;

    if (status == PermissionResult.granted) {
      await _pickImage(source);
    } else if (status == PermissionResult.permanentlyDenied) {
      _showPermissionDialog(source);
    } else {
      _showPermissionSnackbar(source);
    }
  }

  void _showPermissionDialog(ImageSource source) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          source == ImageSource.camera
              ? 'Camera access is required to take food photos. '
                  'Please enable it in Settings.'
              : 'Photo library access is required to select '
                  'food images. Please enable it in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showPermissionSnackbar(ImageSource source) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          source == ImageSource.camera
              ? 'Camera permission is needed to take photos'
              : 'Photo library permission is needed',
        ),
        action: SnackBarAction(
          label: 'Allow',
          onPressed: () => _handleImageSource(source),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = source == ImageSource.camera
          ? await _imagePickerService.pickFromCamera()
          : await _imagePickerService.pickFromGallery();

      if (image != null && mounted) {
        setState(() => _selectedImage = image);
      } else if (!mounted) {
        return;
      }
    } catch (_) {
      _showErrorSnackbar('Failed to load image. Try again.');
    }
  }

  void _removeImage() {
    setState(() => _selectedImage = null);
    context.read<FoodAnalysisBloc>().add(const ResetAnalysisEvent());
  }

  void _onAnalyzeTap() {
    if (_selectedImage == null) return;
    context.read<FoodAnalysisBloc>().add(AnalyzeFoodEvent(_selectedImage!));
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorWithRetry(FoodAnalysisError state) {
    String message;
    switch (state.errorType) {
      case FoodAnalysisErrorType.noInternet:
        message = 'No internet connection. '
            'Check your network and try again.';
        break;
      case FoodAnalysisErrorType.timeout:
        message = 'Analysis timed out. Please try again.';
        break;
      case FoodAnalysisErrorType.invalidResponse:
        message = 'Could not analyze this image. '
            'Try a clearer photo.';
        break;
      case FoodAnalysisErrorType.imageProcessing:
        message = 'Image processing failed. '
            'Try another photo.';
        break;
      case FoodAnalysisErrorType.unknown:
        message = 'Something went wrong. Please try again.';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _onAnalyzeTap,
        ),
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _openResult(FoodRecord record) {
    context.pushNamed(AppRoutes.result, extra: record);
  }

  void _onBlocStateChanged(BuildContext context, FoodAnalysisState state) {
    if (state is FoodAnalysisSuccess) {
      _openResult(state.record);
      // Reset after navigation
      Future.delayed(const Duration(milliseconds: 300), _removeImage);
    } else if (state is FoodAnalysisError) {
      _showErrorWithRetry(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final textColor = palette.text;
    final count = mockRecords.length;

    return BlocConsumer<FoodAnalysisBloc, FoodAnalysisState>(
      listener: _onBlocStateChanged,
      builder: (context, state) {
        final isLoading = state is FoodAnalysisLoading;

        return Scaffold(
          appBar: const HomeAppBar(),
          floatingActionButton: AnimatedScale(
            scale: _showFab ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton(
              onPressed: _scrollToTop,
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
                      // Upload Zone Card
                      UploadZoneCard(
                        selectedImage: _selectedImage,
                        isLoading: isLoading,
                        onCameraTap: () =>
                            _handleImageSource(ImageSource.camera),
                        onGalleryTap: () =>
                            _handleImageSource(ImageSource.gallery),
                        onRemoveImage: _removeImage,
                      ),
                      const SizedBox(height: 14),
                      // Analyze Button
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _canAnalyze && !isLoading ? _onAnalyzeTap : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.primary,
                            disabledBackgroundColor:
                                palette.primary.withValues(alpha: 0.4),
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Analyzing...',
                                      style: AppTextStyles.label
                                          .copyWith(color: Colors.white),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Analyze Food',
                                  style: AppTextStyles.label
                                      .copyWith(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Recent Scans heading
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
                                color: palette.primaryBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$count',
                                style: AppTextStyles.caption
                                    .copyWith(color: palette.primary),
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
              // History list
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
        );
      },
    );
  }
}
