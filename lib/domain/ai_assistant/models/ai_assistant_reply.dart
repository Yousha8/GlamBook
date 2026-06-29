import 'ai_assistant_intent.dart';
import 'ai_assistant_action.dart';
import 'recommended_service_result.dart';

class AiAssistantReply {
  final String message;
  final AiAssistantIntent intent;
  final double confidence;
  final List<RecommendedServiceResult> recommendedServices;
  final List<String> warnings;
  final AiAssistantAction action;

  AiAssistantReply({
    required this.message,
    required this.intent,
    required this.confidence,
    this.recommendedServices = const [],
    this.warnings = const [],
    required this.action,
  });
}
