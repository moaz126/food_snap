import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:food_snap/data/ai/ai_provider.dart';
import 'package:food_snap/data/ai/models/ai_analysis_result.dart';

/// Gemini implementation of AiProvider.
/// SOLID: Single Responsibility — only handles Gemini API.
/// SOLID: Open/Closed — extend AiProvider, never modify it.
class GeminiProvider implements AiProvider {
  final String _apiKey;
  final http.Client _client;

  static const String _model = 'gemini-2.5-flash';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com'
      '/v1beta/models/$_model:generateContent';

  // System prompt shared across all providers
  static const String _systemPrompt = '''
You are a nutrition analysis expert.
Analyze the food image and respond ONLY with 
valid JSON. No markdown. No extra text.
No explanations. No code blocks.

IMPORTANT RULES:
- If you cannot identify the food clearly, 
  still make your best estimate
- NEVER return 0 for calories, protein, 
  carbs, or fat — always estimate realistically
- Minimum calories for any real food: 10 kcal
- If image is not food at all, set 
  confidencePercent to 5 or below
- All numeric values must be positive numbers
- Estimate based on typical serving size 
  if not clear from image

JSON structure:
{
  "detectedFoodName": "string",
  "cuisineTags": ["string"],
  "confidencePercent": number (0-100),
  "nutrition": {
    "calories": number (never 0),
    "protein": number (never 0),
    "carbs": number (can be 0 only for 
              pure protein/fat foods),
    "fat": number (never 0),
    "fiber": number,
    "sugar": number,
    "sodium": number,
    "servingSize": "string"
  },
  "rawSummary": "string"
}
''';

  GeminiProvider({
    required String apiKey,
    http.Client? client,
  })  : _apiKey = apiKey,
        _client = client ?? http.Client();

  @override
  String get providerName => 'Gemini';

  @override
  Future<AiAnalysisResult> analyzeFood(
    File imageFile,
  ) async {
    try {
      final imageBytes = await _compressImage(imageFile);
      final base64Image = base64Encode(imageBytes);

      final url = Uri.parse('$_baseUrl?key=$_apiKey');

      debugPrint('╔══════════════════════════════════════════');
      debugPrint('║ [GeminiProvider] API Call Started');
      debugPrint('║ Model  : $_model');
      debugPrint('║ File   : ${imageFile.path}');
      debugPrint(
          '║ Size   : ${(imageBytes.length / 1024).toStringAsFixed(1)} KB');
      debugPrint('╚══════════════════════════════════════════');

      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'system_instruction': {
                'parts': [
                  {'text': _systemPrompt}
                ]
              },
              'contents': [
                {
                  'parts': [
                    {
                      'inline_data': {
                        'mime_type': 'image/jpeg',
                        'data': base64Image,
                      }
                    },
                    {'text': 'Analyze this food image.'}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.1,
                'maxOutputTokens': 1024,
                'responseMimeType': 'application/json',
              }
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const AiProviderException(
              message: 'Request timed out after 30 seconds',
              type: AiProviderErrorType.timeout,
            ),
          );

      if (response.statusCode == 429) {
        throw const AiProviderException(
          message: 'Rate limit exceeded. Please wait and try again.',
          type: AiProviderErrorType.rateLimitExceeded,
        );
      }

      if (response.statusCode == 400) {
        throw const AiProviderException(
          message: 'Invalid request. Try a different image.',
          type: AiProviderErrorType.invalidResponse,
        );
      }

      if (response.statusCode != 200) {
        throw AiProviderException(
          message: 'API error: ${response.statusCode}',
          type: AiProviderErrorType.unknown,
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final text =
          body['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;

      if (text == null || text.trim().isEmpty) {
        throw const AiProviderException(
          message: 'Empty response from Gemini',
          type: AiProviderErrorType.invalidResponse,
        );
      }

      return _parseResponse(text);
    } on AiProviderException {
      rethrow;
    } on SocketException {
      debugPrint('✗ [GeminiProvider] SocketException — no internet');
      throw const AiProviderException(
        message: 'No internet connection',
        type: AiProviderErrorType.noInternet,
      );
    } on TimeoutException {
      debugPrint('✗ [GeminiProvider] TimeoutException');
      throw const AiProviderException(
        message: 'Request timed out',
        type: AiProviderErrorType.timeout,
      );
    } catch (e) {
      debugPrint('✗ [GeminiProvider] Unknown error: $e');
      throw AiProviderException(
        message: e.toString(),
        type: AiProviderErrorType.unknown,
      );
    }
  }

  /// Compress image before sending to API
  Future<Uint8List> _compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      // image_picker already compresses during picking; keep this as a
      // thin read/fallback layer for provider upload.
      return bytes;
    } catch (e) {
      throw const AiProviderException(
        message: 'Failed to read image file',
        type: AiProviderErrorType.imageProcessing,
      );
    }
  }

  /// Parse and validate JSON response
  AiAnalysisResult _parseResponse(String rawText) {
    debugPrint('╔══════════════════════════════════════════');
    debugPrint('║ [GeminiProvider] Raw Response Received');
    debugPrint('║ Length : ${rawText.length} chars');
    debugPrint('╠══════════════════════════════════════════');
    debugPrint('║ $rawText');
    debugPrint('╚══════════════════════════════════════════');

    try {
      final cleaned =
          rawText.replaceAll('```json', '').replaceAll('```', '').trim();

      if (cleaned.isEmpty) {
        debugPrint('✗ [GeminiProvider] Empty response after cleanup');
        throw const AiProviderException(
          message: 'Empty response received',
          type: AiProviderErrorType.invalidResponse,
        );
      }

      final json = _decodeResponseMap(cleaned);
      final result = AiAnalysisResult.fromJson(_normalizeResponseMap(json));

      debugPrint('✔ [GeminiProvider] Parsed successfully');
      debugPrint('  Food      : ${result.detectedFoodName}');
      debugPrint('  Calories  : ${result.nutrition.calories}');
      debugPrint('  Confidence: ${result.confidencePercent}%');

      return result;
    } on AiProviderException {
      rethrow;
    } on FormatException {
      debugPrint('✗ [GeminiProvider] FormatException — invalid JSON');
      throw const AiProviderException(
        message: 'Could not parse nutrition data. Try a clearer food photo.',
        type: AiProviderErrorType.invalidResponse,
      );
    } catch (e) {
      debugPrint('✗ [GeminiProvider] Parse failed: $e');
      throw const AiProviderException(
        message: 'Unexpected parsing error',
        type: AiProviderErrorType.invalidResponse,
      );
    }
  }

  Map<String, dynamic> _decodeResponseMap(String cleaned) {
    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } on FormatException {
      final repaired = _repairTruncatedJson(cleaned);
      debugPrint('║ [GeminiProvider] Repaired JSON candidate: $repaired');
      try {
        return jsonDecode(repaired) as Map<String, dynamic>;
      } on FormatException {
        final extracted = _extractPartialResponseMap(cleaned);
        debugPrint('║ [GeminiProvider] Extracted partial map: $extracted');
        return extracted;
      }
    }
  }

  String _repairTruncatedJson(String input) {
    var repaired = input.trim();
    repaired = repaired.replaceAll(RegExp(r',\s*$'), '');

    final openCurly = '{'.allMatches(repaired).length;
    final closeCurly = '}'.allMatches(repaired).length;

    if (closeCurly < openCurly) {
      repaired = '$repaired${'}' * (openCurly - closeCurly)}';
    }

    final openSquare = '['.allMatches(repaired).length;
    final closeSquare = ']'.allMatches(repaired).length;
    if (closeSquare < openSquare) {
      repaired = '$repaired${']' * (openSquare - closeSquare)}';
    }

    repaired = repaired.replaceAll(RegExp(r',\s*([}\]])'), r'$1');

    return repaired;
  }

  Map<String, dynamic> _extractPartialResponseMap(String rawText) {
    final detectedFoodName =
        _extractStringField(rawText, 'detectedFoodName') ?? '';
    final confidencePercent =
        _extractNumField(rawText, 'confidencePercent')?.toDouble() ?? 0.0;
    final cuisineTags = _extractStringListField(rawText, 'cuisineTags');

    final nutrition = <String, dynamic>{
      'calories': _extractNumField(rawText, 'calories') ?? 0,
      'protein': _extractNumField(rawText, 'protein') ?? 0,
      'carbs': _extractNumField(rawText, 'carbs') ?? 0,
      'fat': _extractNumField(rawText, 'fat') ?? 0,
      'fiber': _extractNumField(rawText, 'fiber') ?? 0,
      'sugar': _extractNumField(rawText, 'sugar') ?? 0,
      'sodium': _extractNumField(rawText, 'sodium') ?? 0,
      'servingSize': _extractStringField(rawText, 'servingSize') ?? 'Unknown',
    };

    if (detectedFoodName.isEmpty &&
        confidencePercent == 0 &&
        cuisineTags.isEmpty) {
      throw const FormatException('Unable to extract partial response');
    }

    return {
      'detectedFoodName': detectedFoodName,
      'cuisineTags': cuisineTags,
      'confidencePercent': confidencePercent,
      'nutrition': nutrition,
      'rawSummary':
          _extractStringField(rawText, 'rawSummary') ?? 'AI analysis result',
    };
  }

  String? _extractStringField(String text, String field) {
    final match = RegExp('"$field"\\s*:\\s*"([^"]*)"').firstMatch(text);
    return match?.group(1);
  }

  num? _extractNumField(String text, String field) {
    final match =
        RegExp('"$field"\\s*:\\s*(-?\\d+(?:\\.\\d+)?)').firstMatch(text);
    final value = match?.group(1);
    return value == null ? null : num.tryParse(value);
  }

  List<String> _extractStringListField(String text, String field) {
    final blockMatch =
        RegExp('"$field"\\s*:\\s*\\[([\\s\\S]*?)\\]').firstMatch(text);
    final block = blockMatch?.group(1);
    if (block == null || block.trim().isEmpty) {
      return const [];
    }

    return RegExp('"([^"]+)"')
        .allMatches(block)
        .map((match) => match.group(1)!)
        .toList();
  }

  Map<String, dynamic> _normalizeResponseMap(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized.putIfAbsent('rawSummary', () => 'AI analysis result');
    normalized.putIfAbsent('cuisineTags', () => <String>[]);

    final nutrition =
        Map<String, dynamic>.from((normalized['nutrition'] as Map?) ?? {});
    nutrition.putIfAbsent('calories', () => 0);
    nutrition.putIfAbsent('protein', () => 0);
    nutrition.putIfAbsent('carbs', () => 0);
    nutrition.putIfAbsent('fat', () => 0);
    nutrition.putIfAbsent('fiber', () => 0);
    nutrition.putIfAbsent('sugar', () => 0);
    nutrition.putIfAbsent('sodium', () => 0);
    nutrition.putIfAbsent('servingSize', () => 'Unknown');
    normalized['nutrition'] = nutrition;

    return normalized;
  }
}
