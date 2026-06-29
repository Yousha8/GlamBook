import '../../domain/ai_assistant/models/parsed_ai_query.dart';
import '../../domain/ai_assistant/models/ai_assistant_reply.dart';
import '../../domain/ai_assistant/models/ai_assistant_action.dart';
import '../../domain/ai_assistant/models/ai_assistant_intent.dart';
import '../../domain/ai_assistant/models/ai_conversation_turn.dart';
import '../../data/models/user_model.dart';
import '../../data/models/service_model.dart';

import '../../domain/ai_assistant/models/recommended_service_result.dart';
import '../../core/services/ai_assistant_service.dart';
import 'intent_classifier.dart';
import 'query_entity_extractor.dart';
import 'service_recommendation_engine.dart';
import 'response_composer.dart';
import 'conversation_memory_service.dart';

class SalonAiCoordinator {
  final IntentClassifier _intentClassifier;
  final QueryEntityExtractor _entityExtractor;
  final ServiceRecommendationEngine _recommendationEngine;
  final ResponseComposer _responseComposer;
  final ConversationMemoryService _memoryService;
  final AIAssistantService _geminiService;

  SalonAiCoordinator(
    this._intentClassifier,
    this._entityExtractor,
    this._recommendationEngine,
    this._responseComposer,
    this._memoryService,
    this._geminiService,
  );

  Future<AiAssistantReply> processQuery(
    String rawQuery,
    UserModel? userProfile,
    List<ServiceModel> allServices,
    List<CategoryModel> allCategories,
  ) async {
    final session = _memoryService.currentSession;
    final lastIntent = session.lastIntent;

    // 1. Classify Intent (Local - for action detection)
    final intent = _intentClassifier.classify(rawQuery, lastIntent);

    // 2. Extract Entities
    final parsedQuery = _entityExtractor.extract(rawQuery, intent);

    // 3. Generate RESPONSE and RECOMMENDATIONS from Local Expert System (Brain)
    // This ensures consistent logic for both text and interactive cards.
    final brainResponse = await _geminiService.getBeautyReply(
      userMessage: rawQuery,
      availableServices: allServices,
      availableCategories: allCategories,
      userProfile: userProfile,
    );

    final recommendations = brainResponse.topServices;

    // 4. Determine Action based on Local Intent & the Brain's Top Recommendation
    AiAssistantAction action = AiAssistantAction.none();

    if (recommendations.isNotEmpty) {
      final topServiceId = recommendations.first.service.id;
      
      if (intent == AiAssistantIntent.bookingRequest) {
        action = AiAssistantAction(
          type: AiActionType.openBookingSheet,
          payload: {'serviceId': topServiceId},
        );
      } else if (intent == AiAssistantIntent.priceInquiry || intent == AiAssistantIntent.serviceRecommendation) {
        action = AiAssistantAction(
          type: AiActionType.openServiceDetails,
          payload: {'serviceId': topServiceId},
        );
      }
    }

    // 5. Construct Final Reply
    final reply = AiAssistantReply(
      intent: intent,
      message: brainResponse.message,
      confidence: 0.95,
      recommendedServices: recommendations,
      action: action,
    );

    // 6. Save to Context Memory
    final turn = AiConversationTurn(
      userMessage: rawQuery,
      parsedQuery: parsedQuery,
      reply: reply,
      timestamp: DateTime.now(),
    );
    await _memoryService.addTurn(turn);

    return reply;
  }

  Future<void> clearMemory() async {
    await _memoryService.clearSession();
    await _geminiService.clearChatHistory();
  }

  List<AiConversationTurn> getHistory() {
    return _memoryService.currentSession.turns;
  }
}
