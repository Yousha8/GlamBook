import '../../domain/ai_assistant/models/ai_assistant_intent.dart';

class AiAnalyticsService {
  void logQuery(String rawQuery, AiAssistantIntent classifiedIntent, double confidence) {
    // In production, wire to FirebaseAnalytics.instance.logEvent(name: 'ai_query', parameters: {...})
    print('[ANALYTICS] ai_query -> intent: ${classifiedIntent.name}, confidence: $confidence');
  }

  void logRecommendationShown(String serviceId, String serviceName, double score) {
    // FirebaseAnalytics.instance.logEvent(name: 'ai_recommendation_shown', ...)
    print('[ANALYTICS] ai_recommendation_shown -> $serviceName (score: $score)');
  }

  void logBookingConversion(String serviceId) {
    // FirebaseAnalytics.instance.logEvent(name: 'ai_booking_started', ...)
    print('[ANALYTICS] ai_booking_started -> $serviceId');
  }
}
