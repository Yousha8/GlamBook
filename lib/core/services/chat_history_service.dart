import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/chat_message_model.dart';


class ChatHistoryService {
  static const String _storageKey = 'glam_bot_history';
  static const int _maxHistory = 50;

  Future<void> saveMessage(ChatMessage message) async {
    final history = await getHistory();
    history.add(message);
    
    // Keep only last N messages
    if (history.length > _maxHistory) {
      history.removeRange(0, history.length - _maxHistory);
    }

    final prefs = await SharedPreferences.getInstance();
    final String encodedHistory = json.encode(
      history.map((m) => m.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedHistory);
  }

  Future<List<ChatMessage>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedHistory = prefs.getString(_storageKey);
    
    if (encodedHistory == null) return [];

    try {
      final List<dynamic> decodedList = json.decode(encodedHistory);
      return decodedList.map((m) => ChatMessage.fromMap(m)).toList();
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
