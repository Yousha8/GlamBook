import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/service_model.dart';

import 'service_providers.dart';

import '../../application/ai_assistant/intent_classifier.dart';
import '../../application/ai_assistant/query_entity_extractor.dart';
import '../../application/ai_assistant/service_recommendation_engine.dart';
import '../../application/ai_assistant/safety_rules_engine.dart';
import '../../application/ai_assistant/response_composer.dart';
import '../../application/ai_assistant/conversation_memory_service.dart';
import '../../application/ai_assistant/salon_ai_coordinator.dart';
import '../../infrastructure/ai_assistant/ai_analytics_service.dart';
import '../services/ai_assistant_service.dart';

final allServicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamServices();
});

final allCategoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamCategories();
});

final intentClassifierProvider = Provider((ref) => IntentClassifier());
final queryEntityExtractorProvider = Provider((ref) => QueryEntityExtractor());
final safetyRulesEngineProvider = Provider((ref) => SafetyRulesEngine());
final responseComposerProvider = Provider((ref) => ResponseComposer());
final aiAnalyticsServiceProvider = Provider((ref) => AiAnalyticsService());
final aiAssistantServiceProvider = Provider((ref) => AIAssistantService());

final serviceRecommendationEngineProvider = Provider((ref) {
  return ServiceRecommendationEngine(ref.watch(safetyRulesEngineProvider));
});

// Using a FutureProvider to ensure the memory service initializes before use
final conversationMemoryServiceProvider = FutureProvider<ConversationMemoryService>((ref) async {
  final service = ConversationMemoryService();
  await service.init();
  return service;
});

final salonAiCoordinatorProvider = FutureProvider<SalonAiCoordinator>((ref) async {
  final memoryService = await ref.watch(conversationMemoryServiceProvider.future);
  return SalonAiCoordinator(
    ref.watch(intentClassifierProvider),
    ref.watch(queryEntityExtractorProvider),
    ref.watch(serviceRecommendationEngineProvider),
    ref.watch(responseComposerProvider),
    memoryService,
    ref.watch(aiAssistantServiceProvider),
  );
});
