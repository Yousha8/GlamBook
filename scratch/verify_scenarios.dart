import 'package:glam_book/application/ai_assistant/intent_classifier.dart';
import 'package:glam_book/application/ai_assistant/query_entity_extractor.dart';
import 'package:glam_book/application/ai_assistant/safety_rules_engine.dart';
import 'package:glam_book/application/ai_assistant/service_recommendation_engine.dart';
import 'package:glam_book/application/ai_assistant/response_composer.dart';
import 'package:glam_book/application/ai_assistant/conversation_memory_service.dart';
import 'package:glam_book/application/ai_assistant/salon_ai_coordinator.dart';
import 'package:glam_book/core/services/ai_assistant_service.dart';
import 'package:glam_book/data/models/user_model.dart';
import 'package:glam_book/data/models/service_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Setup SharedPreferences mock if running in a pure Dart environment
  SharedPreferences.setMockInitialValues({});
  
  final memory = ConversationMemoryService();
  await memory.init();

  final coordinator = SalonAiCoordinator(
    IntentClassifier(),
    QueryEntityExtractor(),
    ServiceRecommendationEngine(SafetyRulesEngine()),
    ResponseComposer(),
    memory,
    AIAssistantService(),
  );

  final user = UserModel(
    id: '1', fullName: 'Alice', email: '', phone: '', role: UserRole.customer,
    createdAt: DateTime.now(), updatedAt: DateTime.now(),
    skinType: 'oily', skinSensitivity: 'high', skinConcerns: 'acne',
  );

  final categories = [
    CategoryModel(id: 'cat_facials', name: 'Facials', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CategoryModel(id: 'cat_massage', name: 'Massage', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    CategoryModel(id: 'cat_hair', name: 'Hair Services', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
  ];

  final services = [
    ServiceModel(
      id: 'ser1', categoryId: 'cat_facials', name: 'Hydrafacial', description: 'Deep clean', imageUrl: '', 
      price: 5000, durationMinutes: 60, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      targetConcerns: ['dry', 'acne'], notRecommendedFor: ['sensitive skin']
    ),
    ServiceModel(
      id: 'ser2', categoryId: 'cat_facials', name: 'Cleanup', description: 'Basic clean', imageUrl: '', 
      price: 2000, durationMinutes: 30, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      targetConcerns: ['oily', 'acne']
    ),
    ServiceModel(
      id: 'ser3', categoryId: 'cat_massage', name: 'Swedish Massage', description: '', imageUrl: '', 
      price: 4000, durationMinutes: 60, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      targetConcerns: ['stress', 'relax']
    ),
    ServiceModel(
      id: 'ser4', categoryId: 'cat_hair', name: 'Keratin', description: '', imageUrl: '', 
      price: 15000, durationMinutes: 120, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      targetConcerns: ['frizz', 'damage']
    ),
  ];

  final queries = [
    "Hi",
    "I have oily acne skin what do you recommend?",
    "What is the price of hydrafacial?",
    "Which is better for dry frizzy hair?",
    "I want something relaxing",
    "Book me the first one",
    "Is it safe for sensitive skin?",
    "Compare cleanup and hydrafacial",
    "I have a wedding next week what should I do?",
    "I don’t know what service I need",
  ];

  for (int i = 0; i < queries.length; i++) {
    final query = queries[i];
    print('\n=======================================');
    print('SCENARIO ${i + 1}: "$query"');
    final response = await coordinator.processQuery(query, user, services, categories);
    print('INTENT DETECTED: ${response.intent.name}');
    print('REPLY: ${response.message}');
    if (response.recommendedServices.isNotEmpty) {
      print('RECOMMENDATIONS: ${response.recommendedServices.map((e) => e.service.name).toList()}');
    }
    if (response.action.type.name != 'none') {
      print('ACTION TRIGGERED: ${response.action.type.name} with ${response.action.payload}');
    }
  }
}
