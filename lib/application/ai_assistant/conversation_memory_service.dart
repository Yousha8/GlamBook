import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/ai_assistant/models/ai_conversation_session.dart';
import '../../domain/ai_assistant/models/ai_conversation_turn.dart';
import '../../domain/ai_assistant/models/ai_assistant_intent.dart';
import '../../domain/ai_assistant/models/parsed_ai_query.dart';
import '../../domain/ai_assistant/models/ai_assistant_reply.dart';
import '../../domain/ai_assistant/models/ai_assistant_action.dart';

class ConversationMemoryService {
  static const String _storageKey = 'ai_session_memory';
  final String _currentSessionId = 'default_session';
  AiConversationSession? _activeSession;

  Future<void> init() async {
    _activeSession = await _loadSession();
  }

  AiConversationSession get currentSession {
    _activeSession ??= AiConversationSession(sessionId: _currentSessionId, turns: []);
    return _activeSession!;
  }

  Future<void> addTurn(AiConversationTurn turn) async {
    final session = currentSession;
    final updatedTurns = List<AiConversationTurn>.from(session.turns)..add(turn);
    
    // Keep only last N turns for context limits
    if (updatedTurns.length > 20) {
      updatedTurns.removeRange(0, updatedTurns.length - 20);
    }
    
    _activeSession = session.copyWith(turns: updatedTurns);
    await _saveSession(_activeSession!);
  }

  Future<void> clearSession() async {
    _activeSession = AiConversationSession(sessionId: _currentSessionId, turns: []);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // --- Persistence Details (Simplified to keep JSON manual mapping short, 
  // in production you'd use Freezed or JasonSerializable hooks) ---

  Future<void> _saveSession(AiConversationSession session) async {
    final prefs = await SharedPreferences.getInstance();
    // For now we only persist raw user/bot texts so UI can show history.
    // The complex objects (ParseQuery, Reply objects) are kept for during-session memory,
    // but building full manual JSON serialization for all deep models is large.
    // We will save simple representations.
    List<Map<String, dynamic>> rawHistory = session.turns.map((t) => {
      'userMessage': t.userMessage,
      'botMessage': t.reply.message,
      'timestamp': t.timestamp.toIso8601String(),
    }).toList();

    await prefs.setString(_storageKey, jsonEncode(rawHistory));
  }

  Future<AiConversationSession> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null) return AiConversationSession(sessionId: _currentSessionId);

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      final turns = list.map((e) => AiConversationTurn(
        userMessage: e['userMessage'],
        parsedQuery: ParsedAiQuery(intent: AiAssistantIntent.fallbackUnknown, rawQuery: e['userMessage'], normalizedTokens: [], confidence: 0),
        reply: AiAssistantReply(
          message: e['botMessage'],
          intent: AiAssistantIntent.fallbackUnknown,
          confidence: 0,
          action: AiAssistantAction.none()
        ),
        timestamp: DateTime.parse(e['timestamp']),
      )).toList();
      return AiConversationSession(sessionId: _currentSessionId, turns: turns);
    } catch (e) {
      return AiConversationSession(sessionId: _currentSessionId);
    }
  }
}
