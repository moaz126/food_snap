import 'dart:io';

import 'package:food_snap/data/ai/models/ai_analysis_result.dart';

/// SOLID: Interface Segregation + Dependency Inversion
/// All AI providers MUST implement this contract.
/// Repository depends on this — never on concrete class.
abstract class AiProvider {
  /// Unique name of this provider (for logging/debug)
  String get providerName;

  /// Analyze food image and return structured result.
  /// Throws:
  ///   [AiProviderException] on any failure
  Future<AiAnalysisResult> analyzeFood(File imageFile);
}

/// Typed exception — so BLoC can handle errors properly
class AiProviderException implements Exception {
  final String message;
  final AiProviderErrorType type;

  const AiProviderException({
    required this.message,
    required this.type,
  });

  @override
  String toString() => 'AiProviderException[$type]: $message';
}

enum AiProviderErrorType {
  noInternet,
  timeout,
  invalidResponse,
  imageProcessing,
  rateLimitExceeded,
  unauthorized,
  unknown,
}
