import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:food_snap/data/ai/ai_provider.dart';
import 'package:food_snap/data/ai/ai_provider_factory.dart';
import 'package:food_snap/data/ai/models/ai_analysis_result.dart';
import 'package:food_snap/core/errors/failures.dart';
import 'package:food_snap/core/utils/image_storage_service.dart';
import 'package:food_snap/data/database/database_helper.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/domain/repositories/food_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: FoodRepository)
class FoodRepositoryImpl implements FoodRepository {
  final DatabaseHelper _databaseHelper;
  final AiProvider _aiProvider;

  FoodRepositoryImpl({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper,
        _aiProvider = AiProviderFactory.create();

  @override
  Future<FoodRecord> analyzeFood(File imageFile) async {
    // 1. Check file exists
    if (!await imageFile.exists()) {
      throw const AiProviderException(
        message: 'Image file not found',
        type: AiProviderErrorType.imageProcessing,
      );
    }

    // 2. Check file size — max 10MB
    final fileSize = await imageFile.length();
    if (fileSize > 10 * 1024 * 1024) {
      throw const AiProviderException(
        message: 'Image too large. Max size is 10MB.',
        type: AiProviderErrorType.imageProcessing,
      );
    }

    // 3. Call AI provider — AiProviderException propagates naturally to BLoC
    final result = await _aiProvider.analyzeFood(imageFile);

    // 4. Validate result
    _validateResult(result);

    String permanentImagePath;
    try {
      permanentImagePath =
          await ImageStorageService.saveImagePermanently(imageFile);
      debugPrint(
        '[FoodRepositoryImpl] Using permanent image path: $permanentImagePath',
      );
    } catch (e) {
      permanentImagePath = imageFile.path;
      debugPrint('Warning: Image save failed: $e');
      debugPrint(
        '[FoodRepositoryImpl] Falling back to temp image path: $permanentImagePath',
      );
    }

    // 5. Map to FoodRecord
    final record = _mapToFoodRecord(permanentImagePath, result);

    // 6. Save to database — silent failure; user still sees result
    try {
      await _databaseHelper.insertRecord(record);
    } catch (e) {
      debugPrint('DB save failed: $e');
    }

    return record;
  }

  @override
  Future<List<FoodRecord>> getAllRecords() async {
    try {
      return await _databaseHelper.getAllRecords();
    } catch (e) {
      throw DatabaseException(message: 'Failed to load history: $e');
    }
  }

  @override
  Future<FoodRecord?> getRecordById(String id) async {
    try {
      return await _databaseHelper.getRecordById(id);
    } catch (e) {
      throw DatabaseException(message: 'Failed to load record: $e');
    }
  }

  @override
  Future<void> deleteRecord(String id) async {
    try {
      final record = await _databaseHelper.getRecordById(id);

      await _databaseHelper.deleteRecord(id);

      if (record != null && record.imageUri.isNotEmpty) {
        await ImageStorageService.deleteImage(record.imageUri);
      }
    } catch (e) {
      throw DatabaseException(message: 'Failed to delete record: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _databaseHelper.clearAll();
    } catch (e) {
      throw DatabaseException(message: 'Failed to clear history: $e');
    }
  }

  // ── Private helpers ──────────────────────────────

  void _validateResult(AiAnalysisResult result) {
    // Check food name
    if (result.detectedFoodName.trim().isEmpty) {
      throw const AiProviderException(
        message: 'Could not identify food in image. '
            'Try a clearer photo.',
        type: AiProviderErrorType.invalidResponse,
      );
    }

    // Low confidence — not a food image
    if (result.confidencePercent <= 5) {
      throw const AiProviderException(
        message: 'This does not appear to be a food image. '
            'Please take a photo of food.',
        type: AiProviderErrorType.invalidResponse,
      );
    }

    // All main macros are 0 — clearly wrong response
    final nutrition = result.nutrition;
    final allZero = nutrition.calories == 0 &&
        nutrition.protein == 0 &&
        nutrition.carbs == 0 &&
        nutrition.fat == 0;

    if (allZero) {
      throw const AiProviderException(
        message: 'Could not analyze nutrition for '
            'this image. Try a clearer food photo.',
        type: AiProviderErrorType.invalidResponse,
      );
    }

    // Unrealistically low calories — any real food has at least 10 kcal
    if (nutrition.calories > 0 && nutrition.calories < 10) {
      throw const AiProviderException(
        message: 'Nutrition data seems incorrect. '
            'Try a clearer photo.',
        type: AiProviderErrorType.invalidResponse,
      );
    }
  }

  FoodRecord _mapToFoodRecord(String imagePath, AiAnalysisResult result) {
    return FoodRecord(
      id: const Uuid().v4(),
      imageUri: imagePath,
      detectedFoodName: result.detectedFoodName.trim(),
      cuisineTags: result.cuisineTags,
      confidencePercent: result.confidencePercent.clamp(0.0, 100.0),
      nutrition: NutritionInfo(
        calories: result.nutrition.calories,
        protein: result.nutrition.protein,
        carbs: result.nutrition.carbs,
        fat: result.nutrition.fat,
        fiber: result.nutrition.fiber,
        sugar: result.nutrition.sugar,
        sodium: result.nutrition.sodium,
        servingSize: result.nutrition.servingSize,
      ),
      rawApiSummary: result.rawSummary,
      createdAt: DateTime.now(),
    );
  }
}
