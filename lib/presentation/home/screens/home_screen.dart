import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/di/injection_container.dart';
import 'package:food_snap/core/navigation/app_router.dart';
import 'package:food_snap/core/theme/app_palette.dart';
import 'package:food_snap/core/utils/image_picker_service.dart';
import 'package:food_snap/core/utils/permission_handler_helper.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/domain/usecases/delete_all_records.dart';
import 'package:food_snap/domain/usecases/delete_record.dart';
import 'package:food_snap/presentation/home/bloc/history_cubit.dart';
import 'package:food_snap/presentation/home/bloc/history_state.dart';
import 'package:food_snap/presentation/home/widgets/analyze_button.dart';
import 'package:food_snap/presentation/home/widgets/history_empty_state.dart';
import 'package:food_snap/presentation/home/widgets/history_error_view.dart';
import 'package:food_snap/presentation/home/widgets/history_loading_skeleton.dart';
import 'package:food_snap/presentation/home/widgets/history_section_header.dart';
import 'package:food_snap/presentation/home/widgets/home_app_bar.dart';
import 'package:food_snap/presentation/home/widgets/slidable_history_tile.dart';
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
  int _snackBarToken = 0;

  bool get _canAnalyze => _selectedImage != null;

  // MARK: - Lifecycle

  @override
  void initState() {
    super.initState();
    _imagePickerService = ImagePickerService();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<HistoryCubit>().loadHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // MARK: - Scroll

  void _onScroll() {
    final show = _scrollController.offset > 300;
    if (show != _showFab) setState(() => _showFab = show);
  }

  // MARK: - Image Picking

  Future<void> _handleImageSource(ImageSource source) async {
    if (source == ImageSource.gallery) {
      await _pickImage(source);
      return;
    }
    final status = await PermissionHandlerHelper.requestCamera();
    if (!mounted) return;
    if (status == PermissionResult.granted) {
      await _pickImage(source);
    } else if (status == PermissionResult.limited) {
      // Treat same as granted — app can still work
      await _pickImage(source);
    } else if (status == PermissionResult.permanentlyDenied) {
      _showPermissionDialog(source);
    } else if (status == PermissionResult.restricted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Access restricted by device policy. '
            'Contact your device administrator.',
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      _showPermissionSnackbar(source);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = source == ImageSource.camera
          ? await _imagePickerService.pickFromCamera()
          : await _imagePickerService.pickFromGallery();
      if (image != null && mounted) {
        setState(() => _selectedImage = image);
      }
    } catch (_) {
      if (mounted) _showErrorSnackbar('Failed to load image. Try again.');
    }
  }

  void _removeImage() {
    setState(() => _selectedImage = null);
    context.read<FoodAnalysisBloc>().add(const ResetAnalysisEvent());
  }

  void _onAnalyzeTap() {
    if (context.read<FoodAnalysisBloc>().state is FoodAnalysisLoading) return;
    if (_selectedImage == null) return;
    context.read<FoodAnalysisBloc>().add(AnalyzeFoodEvent(_selectedImage!));
  }

  // MARK: - BLoC Handlers

  void _onAnalysisStateChanged(
    BuildContext context,
    FoodAnalysisState state,
  ) {
    if (state is FoodAnalysisSuccess) {
      _handleAnalysisSuccess(context, state);
    } else if (state is FoodAnalysisError) {
      _showErrorWithRetry(context, state);
    }
  }

  Future<void> _handleAnalysisSuccess(
    BuildContext context,
    FoodAnalysisSuccess state,
  ) async {
    // Reload history BEFORE navigating so new item is visible when user returns
    await context.read<HistoryCubit>().refresh();
    if (!context.mounted) return;

    // pushNamed awaits until the user pops back from the result screen
    await context.pushNamed(AppRoutes.result, extra: state.record);
    if (!context.mounted) return;

    // Clean up after user returns: clear selected image + reset BLoC
    _removeImage();
  }

  // MARK: - UI Builders

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodAnalysisBloc, FoodAnalysisState>(
      listener: _onAnalysisStateChanged,
      builder: (context, analysisState) {
        final isLoading = analysisState is FoodAnalysisLoading;

        return PopScope(
          canPop: !isLoading,
          // ignore: deprecated_member_use
          onPopInvoked: (didPop) async {
            if (didPop) return;
            final shouldCancel = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Cancel Analysis?'),
                content: const Text(
                  'Analysis is in progress. '
                  'Are you sure you want to cancel?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Keep Waiting'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            );
            if (shouldCancel == true && context.mounted) {
              context.read<FoodAnalysisBloc>().add(const ResetAnalysisEvent());
            }
          },
          child: Scaffold(
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
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () => context.read<HistoryCubit>().refresh(),
                ),
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
                        AnalyzeButton(
                          canAnalyze: _canAnalyze,
                          isLoading: isLoading,
                          onTap: _onAnalyzeTap,
                        ),
                        const SizedBox(height: 28),
                        // Recent Scans Heading
                        HistorySectionHeader(
                          onDeleteAllTap: () => _onDeleteAllTap(context),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                // History Content
                BlocBuilder<HistoryCubit, HistoryState>(
                  builder: (context, historyState) {
                    return SliverToBoxAdapter(
                      child: switch (historyState) {
                        HistoryLoading() => const HistoryLoadingSkeleton(),
                        HistoryLoaded(:final records) =>
                          _buildHistoryList(context, records),
                        HistoryEmpty() => const HistoryEmptyState(),
                        HistoryError(:final message) => HistoryErrorView(
                            message: message,
                            onRetry: () =>
                                context.read<HistoryCubit>().loadHistory(),
                          ),
                        _ => const SizedBox.shrink(),
                      },
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onDeleteAllTap(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Scans?'),
        content: const Text(
          'This will permanently remove all your scan history. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete All',
              style: TextStyle(color: ctx.appPalette.coral),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<HistoryCubit>().deleteAll(sl<DeleteAllRecords>());
    }
  }

  // MARK: - History State UI Builders

  Widget _buildHistoryList(
    BuildContext context,
    List<FoodRecord> records,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: records.map((record) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SlidableHistoryTile(
              key: Key(record.id),
              record: record,
              onTap: () => _openResult(record),
              onDeleteConfirmed: () {
                context
                    .read<HistoryCubit>()
                    .deleteRecord(record.id, sl<DeleteRecord>());
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // MARK: - Helpers

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _openResult(FoodRecord record) {
    // verify it still exists in DB before navigating.
    context.pushNamed(AppRoutes.result, extra: record);
  }

  String _getErrorMessage(FoodAnalysisError state) {
    final trimmedMessage = state.message.trim();
    if (trimmedMessage.isNotEmpty &&
        state.errorType == FoodAnalysisErrorType.invalidResponse) {
      return trimmedMessage;
    }

    final type = state.errorType;
    return switch (type) {
      FoodAnalysisErrorType.noInternet =>
        'No internet connection. Check your network and try again.',
      FoodAnalysisErrorType.timeout => 'Analysis timed out. Please try again.',
      FoodAnalysisErrorType.invalidResponse =>
        'Could not analyze this image. Try a clearer photo of the food.',
      FoodAnalysisErrorType.imageProcessing =>
        'Image processing failed. Try selecting another photo.',
      FoodAnalysisErrorType.unknown =>
        'Something went wrong. Please try again.',
    };
  }

  void _showErrorWithRetry(BuildContext context, FoodAnalysisError state) {
    _showTimedSnackBar(
      context,
      SnackBar(
        content: Text(_getErrorMessage(state)),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.fixed,
        action: state.errorType != FoodAnalysisErrorType.imageProcessing
            ? SnackBarAction(
                label: 'Retry',
                onPressed: _onAnalyzeTap,
              )
            : null,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    _showTimedSnackBar(
      context,
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.fixed,
      ),
    );
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
    _showTimedSnackBar(
      context,
      SnackBar(
        content: Text(
          source == ImageSource.camera
              ? 'Camera permission is needed to take photos'
              : 'Photo library permission is needed',
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.fixed,
        action: SnackBarAction(
          label: 'Allow',
          onPressed: () => _handleImageSource(source),
        ),
      ),
    );
  }

  void _showTimedSnackBar(BuildContext context, SnackBar snackBar) {
    final messenger = ScaffoldMessenger.of(context);
    final currentToken = ++_snackBarToken;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(snackBar);

    Future.delayed(snackBar.duration, () {
      if (!mounted || currentToken != _snackBarToken) {
        return;
      }
      messenger.hideCurrentSnackBar();
    });
  }
}
