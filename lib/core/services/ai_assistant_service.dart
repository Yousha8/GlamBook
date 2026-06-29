import 'glam_brain_service.dart';
import 'chat_history_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/service_model.dart';
import '../../data/models/chat_message_model.dart';

/// Main Service for the AI Assistant, now operating as a Local Expert System (FYP).
/// It coordinates between history management and the local rule-based brain.
class AIAssistantService {
  final ChatHistoryService _historyService = ChatHistoryService();
  
  AIAssistantService();

  Future<BrainResponse> getBeautyReply({
    required String userMessage,
    required List<ServiceModel> availableServices,
    required List<CategoryModel> availableCategories,
    UserModel? userProfile,
  }) async {
    try {
      // 1. Save user message to history
      final userMsg = ChatMessage(
        content: userMessage,
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );
      await _historyService.saveMessage(userMsg);

      // 2. Process query using Local Expert System (Rule-Based)
      final brain = GlamBrainService(availableServices, availableCategories);
      
      // Step into the local logic pipeline to get structured response
      final brainResponse = brain.generateExpertReply(userMessage, userProfile);

      // 3. Save bot response to history
      final botMsg = ChatMessage(
        content: brainResponse.message,
        role: MessageRole.bot,
        timestamp: DateTime.now(),
      );
      await _historyService.saveMessage(botMsg);

      return brainResponse;
    } catch (e) {
      print('GlamBot (Expert System) Error: $e');
      return BrainResponse(
        "I'm sorry, I'm having trouble accessing my beauty catalog right now. ✨ Could you try rephrasing?",
        []
      );
    }
  }

  Future<List<ChatMessage>> getChatHistory() async {
    return _historyService.getHistory();
  }

  Future<void> clearChatHistory() async {
    await _historyService.clearHistory();
  }
}
