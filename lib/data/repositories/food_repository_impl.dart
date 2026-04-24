import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_snap/core/constants/app_constants.dart';
import 'package:food_snap/core/errors/failures.dart';
import 'package:food_snap/data/database/database_helper.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/domain/repositories/food_repository.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: FoodRepository)
class FoodRepositoryImpl implements FoodRepository {
  final DatabaseHelper databaseHelper;

  FoodRepositoryImpl({required this.databaseHelper});

  @override
  Future<FoodRecord> analyzeFood(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        throw const ImageCompressionFailure(message: 'Image file not found');
      }

      final base64Image = await _prepareBase64Image(imageFile);
      final responseText = await _requestAnthropic(base64Image);
      final parsed = _parseAnthropicResponse(responseText);

      final nutritionJson = parsed['nutrition'] as Map<String, dynamic>;

      final record = FoodRecord(
        id: const Uuid().v4(),
        imageUri: imageFile.path,
        detectedFoodName: (parsed['detectedFoodName'] ?? 'Unknown') as String,
        cuisineTags: List<String>.from(
            parsed['cuisineTags'] as List<dynamic>? ?? <String>[]),
        confidencePercent:
            (parsed['confidencePercent'] as num?)?.toDouble() ?? 0,
        nutrition: NutritionInfo(
          calories: (nutritionJson['calories'] as num?)?.toDouble() ?? 0,
          protein: (nutritionJson['protein'] as num?)?.toDouble() ?? 0,
          carbs: (nutritionJson['carbs'] as num?)?.toDouble() ?? 0,
          fat: (nutritionJson['fat'] as num?)?.toDouble() ?? 0,
          fiber: (nutritionJson['fiber'] as num?)?.toDouble(),
          sugar: (nutritionJson['sugar'] as num?)?.toDouble(),
          sodium: (nutritionJson['sodium'] as num?)?.toDouble(),
          servingSize: nutritionJson['servingSize'] as String?,
        ),
        rawApiSummary: (parsed['rawSummary'] ?? '') as String,
        createdAt: DateTime.now(),
      );

      await databaseHelper.insertRecord(record);
      return record;
    } on SocketException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const TimeoutFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(message: 'Analyze failed: $e');
    }
  }

  Future<String> _prepareBase64Image(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw ImageCompressionFailure(message: 'Failed to read image: $e');
    }
  }

  Future<String> _requestAnthropic(String base64Image) async {
    final apiKey = dotenv.env[AppConstants.anthropicApiKeyEnv];
    if (apiKey == null || apiKey.isEmpty) {
      throw const UnknownFailure(message: 'Missing ANTHROPIC_API_KEY in .env');
    }

    final body = {
      'model': AppConstants.anthropicModel,
      'max_tokens': 1024,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': 'image/jpeg',
                'data': base64Image,
              },
            },
            {
              'type': 'text',
              'text': 'Analyze this food image...',
            },
          ],
        },
      ],
      'system': AppConstants.nutritionSystemPrompt,
    };

    final response = await http
        .post(
          Uri.parse(AppConstants.anthropicEndpoint),
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: AppConstants.apiTimeoutSeconds));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw InvalidApiResponseFailure(
        message: 'API request failed (${response.statusCode})',
      );
    }

    final root = jsonDecode(response.body) as Map<String, dynamic>;
    final content = root['content'] as List<dynamic>?;
    if (content == null || content.isEmpty) {
      throw const InvalidApiResponseFailure(message: 'Empty API content');
    }

    final text = (content.first as Map<String, dynamic>)['text'];
    if (text is! String || text.trim().isEmpty) {
      throw const InvalidApiResponseFailure(
          message: 'Invalid API text payload');
    }

    return text;
  }

  Map<String, dynamic> _parseAnthropicResponse(String responseText) {
    try {
      final clean =
          responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final jsonMap = jsonDecode(clean) as Map<String, dynamic>;
      if (!jsonMap.containsKey('nutrition')) {
        throw const InvalidApiResponseFailure(
            message: 'Missing nutrition data');
      }
      return jsonMap;
    } on FormatException catch (e) {
      throw InvalidApiResponseFailure(
          message: 'JSON parse failed: ${e.message}');
    }
  }

  @override
  Future<List<FoodRecord>> getAllRecords() {
    return databaseHelper.getAllRecords();
  }

  @override
  Future<FoodRecord?> getRecordById(String id) {
    return databaseHelper.getRecordById(id);
  }

  @override
  Future<void> deleteRecord(String id) {
    return databaseHelper.deleteRecord(id);
  }

  @override
  Future<void> clearAll() {
    return databaseHelper.clearAll();
  }
}
