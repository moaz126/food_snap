import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_snap/data/ai/ai_provider.dart';
import 'package:food_snap/data/ai/providers/claude_provider.dart';
import 'package:food_snap/data/ai/providers/gemini_provider.dart';
import 'package:food_snap/data/ai/providers/openai_provider.dart';

/// Factory — decides which provider to use.
/// Change active provider from .env — no code change needed.
///
/// .env:
///   AI_PROVIDER=gemini   → GeminiProvider
///   AI_PROVIDER=claude   → ClaudeProvider
///   AI_PROVIDER=openai   → OpenAiProvider
class AiProviderFactory {
  AiProviderFactory._(); // prevent instantiation

  static AiProvider create() {
    final provider = dotenv.env['AI_PROVIDER'] ?? 'gemini';

    switch (provider.toLowerCase()) {
      case 'claude':
        final key = dotenv.env['ANTHROPIC_API_KEY'] ?? '';
        if (key.isEmpty) {
          throw Exception(
            'ANTHROPIC_API_KEY missing in .env',
          );
        }
        return ClaudeProvider(apiKey: key);

      case 'openai':
        final key = dotenv.env['OPENAI_API_KEY'] ?? '';
        if (key.isEmpty) {
          throw Exception(
            'OPENAI_API_KEY missing in .env',
          );
        }
        return OpenAiProvider(apiKey: key);

      case 'gemini':
      default:
        final key = dotenv.env['GEMINI_API_KEY'] ?? '';
        if (key.isEmpty) {
          throw Exception(
            'GEMINI_API_KEY missing in .env',
          );
        }
        return GeminiProvider(apiKey: key);
    }
  }
}
