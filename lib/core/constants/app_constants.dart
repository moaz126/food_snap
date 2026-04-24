class AppConstants {
  AppConstants._();

  static const String anthropicApiKeyEnv = 'ANTHROPIC_API_KEY';
  static const String anthropicModel = 'claude-sonnet-4-20250514';
  static const String anthropicEndpoint = 'https://api.anthropic.com/v1/messages';
  static const int apiTimeoutSeconds = 30;

  static const String dbName = 'food_snap.db';
  static const int dbVersion = 1;
  static const String tableFoodRecords = 'food_records';

  static const int imageMaxDimension = 1024;
  static const int imageQuality = 85;

  static const String nutritionSystemPrompt =
      'You are a nutrition analysis expert. '
      'Respond ONLY with valid JSON. No extra text. No markdown. '
      'JSON structure: {'
      'detectedFoodName: string, '
      'cuisineTags: string[], '
      'confidencePercent: number, '
      'nutrition: {'
      'calories: number, '
      'protein: number, '
      'carbs: number, '
      'fat: number, '
      'fiber: number, '
      'sugar: number, '
      'sodium: number, '
      'servingSize: string'
      '}, '
      'rawSummary: string'
      '}';
}
