import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_snap/core/navigation/app_router.dart';
import 'package:food_snap/core/theme/theme_cubit.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/presentation/home/bloc/history_cubit.dart';
import 'package:food_snap/presentation/home/bloc/history_state.dart';
import 'package:food_snap/presentation/home/widgets/food_history_tile.dart';
import 'package:food_snap/presentation/home/widgets/upload_zone_card.dart';
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
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().load();
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked == null || !mounted) {
        return;
      }

      context.read<FoodAnalysisBloc>().add(
            AnalyzeFoodEvent(imageFile: File(picked.path)),
          );
    } catch (_) {
      if (!mounted) {
        return;
      }
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

  void _openResult(FoodRecord record) {
    context.goNamed(
      AppRoutes.result,
      extra: record,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FoodAnalysisBloc, FoodAnalysisState>(
      listener: (context, state) {
        if (state is FoodAnalysisError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {},
              ),
            ),
          );
        }

        if (state is FoodAnalysisSuccess) {
          context.read<HistoryCubit>().load();
          _openResult(state.record);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FoodSnap'),
          actions: [
            IconButton(
              onPressed: () => context.read<ThemeCubit>().toggle(),
              icon: const Icon(Icons.brightness_6_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BlocBuilder<FoodAnalysisBloc, FoodAnalysisState>(
              builder: (context, state) {
                return UploadZoneCard(
                  onCamera: () => _pickAndAnalyze(ImageSource.camera),
                  onGallery: () => _pickAndAnalyze(ImageSource.gallery),
                  isLoading: state is FoodAnalysisLoading,
                );
              },
            ),
            const SizedBox(height: 16),
            Text('History', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is HistoryError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.message),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.read<HistoryCubit>().load(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is HistoryEmpty || state is HistoryInitial) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No records yet. Analyze your first meal.'),
                    ),
                  );
                }

                final records = (state as HistoryLoaded).records;
                return Column(
                  children: records
                      .map(
                        (record) => FoodHistoryTile(
                          record: record,
                          onTap: () => _openResult(record),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
