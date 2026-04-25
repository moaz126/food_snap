import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:food_snap/data/ai/ai_provider.dart';
import 'package:food_snap/data/ai/models/ai_analysis_result.dart';

/// OpenAI GPT-4o implementation — ready when needed.
/// Just add OPENAI_API_KEY to .env to activate.
class OpenAiProvider implements AiProvider {
  final String _apiKey;
  final http.Client _client;

  static const String _model = 'gpt-4o';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  static const String _systemPrompt = '''
You are a nutrition analysis expert.
Analyze the food image and respond ONLY with valid JSON.
No markdown. No extra text. No explanations.

JSON structure:
{
  "detectedFoodName": "string",
  "cuisineTags": ["string"],
  "confidencePercent": number (0-100),
  "nutrition": {
    "calories": number,
    "protein": number,
    "carbs": number,
    "fat": number,
    "fiber": number,
    "sugar": number,
    "sodium": number,
    "servingSize": "string"
  },
  "rawSummary": "string"
}
''';

  OpenAiProvider({
    required String apiKey,
    http.Client? client,
  })  : _apiKey = apiKey,
        _client = client ?? http.Client();

  @override
  String get providerName => 'OpenAI';

  @override
  Future<AiAnalysisResult> analyzeFood(
    File imageFile,
  ) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await _client
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'max_tokens': 1024,
              'messages': [
                {
                  'role': 'system',
                  'content': _systemPrompt,
                },
                {
                  'role': 'user',
                  'content': [
                    {
                      'type': 'image_url',
                      'image_url': {
                        'url': 'data:image/jpeg;base64,$base64Image',
                      },
                    },
                    {
                      'type': 'text',
                      'text': 'Analyze this food image.',
                    },
                  ],
                }
              ],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw AiProviderException(
          message: 'OpenAI error: ${response.statusCode}',
          type: AiProviderErrorType.unknown,
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final text = body['choices'][0]['message']['content'] as String;

      return _parseResponse(text);
    } on AiProviderException {
      rethrow;
    } on SocketException {
      throw const AiProviderException(
        message: 'No internet connection',
        type: AiProviderErrorType.noInternet,
      );
    } catch (e) {
      throw AiProviderException(
        message: e.toString(),
        type: AiProviderErrorType.unknown,
      );
    }
  }

  AiAnalysisResult _parseResponse(String rawText) {
    try {
      final cleaned =
          rawText.replaceAll('```json', '').replaceAll('```', '').trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      return AiAnalysisResult.fromJson(json);
    } catch (e) {
      throw const AiProviderException(
        message: 'Failed to parse response',
        type: AiProviderErrorType.invalidResponse,
      );
    }
  }
}
