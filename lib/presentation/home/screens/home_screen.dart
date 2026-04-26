import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  late final ScrollController _scrollController;
  late final ImagePickerService _imagePickerService;
  late final AnimationController _shimmerController;
  bool _showFab = false;
  int _snackBarToken = 0;

  bool get _canAnalyze => _selectedImage != null;

  // MARK: - Lifecycle

  @override
  void initState() {
    super.initState();
    _imagePickerService = ImagePickerService();
    _scrollController = ScrollController()..addListener(_onScroll);
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    context.read<HistoryCubit>().loadHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _shimmerController.dispose();
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
        final palette = context.appPalette;

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
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _canAnalyze && !isLoading
                                ? _onAnalyzeTap
                                : null,
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
                            child: Text(
                              'Analyze Food',
                              style: AppTextStyles.label
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Recent Scans Heading
                        _buildHistoryHeading(context, palette),
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
                        HistoryLoading() => _buildHistoryLoading(palette),
                        HistoryLoaded(:final records) =>
                          _buildHistoryList(context, records, palette),
                        HistoryEmpty() => _buildEmptyState(palette),
                        HistoryError(:final message) =>
                          _buildHistoryError(context, message, palette),
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

  Widget _buildHistoryHeading(BuildContext context, AppPalette palette) {
    return Row(
      children: [
        Text(
          'Recent Scans',
          style: AppTextStyles.h3.copyWith(color: palette.text),
        ),
        const SizedBox(width: 8),
        BlocBuilder<HistoryCubit, HistoryState>(
          buildWhen: (prev, curr) {
            final prevCount =
                prev is HistoryLoaded ? prev.records.length : null;
            final currCount =
                curr is HistoryLoaded ? curr.records.length : null;
            return prevCount != currCount;
          },
          builder: (context, state) {
            if (state is HistoryLoaded && state.records.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: palette.primaryBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${state.records.length}',
                  style: AppTextStyles.caption.copyWith(color: palette.primary),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const Spacer(),
        BlocBuilder<HistoryCubit, HistoryState>(
          buildWhen: (prev, curr) =>
              (prev is HistoryLoaded) != (curr is HistoryLoaded),
          builder: (context, state) {
            if (state is! HistoryLoaded || state.records.isEmpty) {
              return const SizedBox.shrink();
            }
            return TextButton.icon(
              onPressed: () => _onDeleteAllTap(context),
              style: TextButton.styleFrom(
                foregroundColor: palette.coral,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: Text(
                'Delete All',
                style: AppTextStyles.caption.copyWith(color: palette.coral),
              ),
            );
          },
        ),
      ],
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

  Widget _buildHistoryLoading(AppPalette palette) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final opacity = 0.3 + (_shimmerController.value * 0.4);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildSkeletonTile(palette, opacity),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonTile(AppPalette palette, double opacity) {
    final shimmerColor = palette.surface2.withValues(alpha: opacity);
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Thumbnail placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name placeholder
              Container(
                width: 140,
                height: 14,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              // Timestamp placeholder
              Container(
                width: 90,
                height: 12,
                decoration: BoxDecoration(
                  color: palette.surface2.withValues(alpha: opacity * 0.75),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<FoodRecord> records,
    AppPalette palette,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: records.map((record) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SlidableHistoryTile(
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

  Widget _buildEmptyState(AppPalette palette) {
    return SizedBox(
      height: 240,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 64,
              color: palette.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No scans yet',
              style: AppTextStyles.label.copyWith(color: palette.text),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyze your first meal above',
              style: AppTextStyles.caption.copyWith(color: palette.textSub),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryError(
    BuildContext context,
    String message,
    AppPalette palette,
  ) {
    return SizedBox(
      height: 240,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: palette.coral, size: 48),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                style: AppTextStyles.body.copyWith(color: palette.textSub),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: Icon(Icons.refresh, color: palette.primary),
              label: Text(
                'Try Again',
                style: AppTextStyles.label.copyWith(color: palette.primary),
              ),
              onPressed: () => context.read<HistoryCubit>().loadHistory(),
            ),
          ],
        ),
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
    // TODO: If record comes from a notification or deep link,
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

// ─────────────────────────────────────────────────────────────────────────────
// _SlidableHistoryTile
// Partial swipe reveals delete button; tap delete → confirm dialog
// ─────────────────────────────────────────────────────────────────────────────

class _SlidableHistoryTile extends StatefulWidget {
  final FoodRecord record;
  final VoidCallback onTap;
  final VoidCallback onDeleteConfirmed;

  const _SlidableHistoryTile({
    super.key,
    required this.record,
    required this.onTap,
    required this.onDeleteConfirmed,
  });

  @override
  State<_SlidableHistoryTile> createState() => _SlidableHistoryTileState();
}

class _SlidableHistoryTileState extends State<_SlidableHistoryTile>
    with SingleTickerProviderStateMixin {
  static const double _actionWidth = 72.0;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      lowerBound: 0,
      upperBound: _actionWidth,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _controller.value =
        (_controller.value - details.delta.dx).clamp(0.0, _actionWidth);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_controller.value > _actionWidth * 0.4) {
      _controller.animateTo(_actionWidth, curve: Curves.easeOut);
    } else {
      _controller.animateTo(0, curve: Curves.easeOut);
    }
  }

  void _close() {
    _controller.animateTo(0, curve: Curves.easeOut);
  }

  Future<void> _onDeleteTap() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Scan?'),
        content: const Text('This scan will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: TextStyle(color: ctx.appPalette.coral),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true) {
      widget.onDeleteConfirmed();
    } else {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Delete action background
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _onDeleteTap,
                    child: Container(
                      width: _actionWidth,
                      color: palette.coral,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Tile slides left
              Transform.translate(
                offset: Offset(-_controller.value, 0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: _onHorizontalDragUpdate,
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  onTap: _controller.value > 1 ? _close : widget.onTap,
                  child: FoodHistoryTile(
                    record: widget.record,
                    onTap: _controller.value > 1 ? _close : widget.onTap,
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
