import 'ai_conversation_turn.dart';
import '../../../data/models/service_model.dart';
import 'ai_assistant_intent.dart';
import 'parsed_ai_query.dart';

class AiConversationSession {
  final String sessionId;
  final List<AiConversationTurn> turns;
  
  // Context shortcuts
  List<ServiceModel> get lastRecommendedServices {
    if (turns.isEmpty) return [];
    return turns.last.reply.recommendedServices.map((r) => r.service).toList();
  }

  AiAssistantIntent? get lastIntent {
    if (turns.isEmpty) return null;
    return turns.last.parsedQuery.intent;
  }

  ParsedAiQuery? get lastEntities {
    if (turns.isEmpty) return null;
    return turns.last.parsedQuery;
  }

  AiConversationSession({
    required this.sessionId,
    this.turns = const [],
  });

  AiConversationSession copyWith({
    String? sessionId,
    List<AiConversationTurn>? turns,
  }) {
    return AiConversationSession(
      sessionId: sessionId ?? this.sessionId,
      turns: turns ?? this.turns,
    );
  }
}
