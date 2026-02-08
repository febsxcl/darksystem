import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatHistoryService {
  Future<void> saveHistory(String topic, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final history = messages.map((m) => m.toJson()).toList();
    await prefs.setString(topic, jsonEncode(history));
  }

  Future<List<ChatMessage>> getHistory(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(topic);
    if (historyString == null) {
      return [];
    }
    final history = jsonDecode(historyString) as List;
    return history.map((json) => ChatMessage.fromJson(json)).toList();
  }
}
