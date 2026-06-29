import 'parsed_ai_query.dart';
import 'ai_assistant_reply.dart';

class AiConversationTurn {
  final String userMessage;
  final ParsedAiQuery parsedQuery;
  final AiAssistantReply reply;
  final DateTime timestamp;

  AiConversationTurn({
    required this.userMessage,
    required this.parsedQuery,
    required this.reply,
    required this.timestamp,
  });
}
