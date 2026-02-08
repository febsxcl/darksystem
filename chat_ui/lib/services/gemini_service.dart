// C:/mark/DarkSystem-main/chat_ui/lib/services/gemini_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class GeminiService {
  // Siguraduhing valid at hindi expired ang API Key na ito.
  static const String apiKey = 'AIzaSyAmBfzqPYYeui5pmfsz8TR2CEE4I2owxag';

  // --- TAMANG API ENDPOINT ---
  // ANG PAGBABAGO AY NANDITO: Pinalitan ang 'v1beta' ng 'v1'.
  static const String apiUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash-latest:generateContent';

  // (Walang binago sa function na ito)
  static List<Map<String, dynamic>> _formatMessages(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return [];
    }
    // ... ang iyong _formatMessages logic ay mananatili dito
    final List<Map<String, dynamic>> formattedMessages = [];
    var lastRole = messages.first.role;
    var combinedText = StringBuffer(messages.first.text);

    for (int i = 1; i < messages.length; i++) {
      final currentMessage = messages[i];
      if (currentMessage.role == lastRole) {
        combinedText.write('\n${currentMessage.text}');
      } else {
        if (lastRole == 'user' || lastRole == 'model') {
          formattedMessages.add({
            'role': lastRole,
            'parts': [{'text': combinedText.toString()}],
          });
        }
        lastRole = currentMessage.role;
        combinedText = StringBuffer(currentMessage.text);
      }
    }

    if (lastRole == 'user' || lastRole == 'model') {
      formattedMessages.add({
        'role': lastRole,
        'parts': [{'text': combinedText.toString()}],
      });
    }

    return formattedMessages;
  }

  // Inayos para gamitin ang tamang 'apiUrl'
  static Future<String> sendMultiTurnMessage(
      List<ChatMessage> conversationHistory,
      String newUserMessage,
      ) async {
    final updatedHistory = List<ChatMessage>.from(conversationHistory);
    updatedHistory.add(ChatMessage(
      text: newUserMessage,
      role: 'user',
      timestamp: DateTime.now(),
    ));

    try {
      final formattedMessages = _formatMessages(updatedHistory);

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'), // Ginamit ang tamang apiUrl
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': formattedMessages,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 1,
            'topP': 1,
            'maxOutputTokens': 2048,
          }
        }),
      );
      return _handleApiResponse(response);
    } catch (e) {
      print('Network Exception: $e');
      return 'Network Error: $e';
    }
  }

  // Inayos din para gamitin ang tamang 'apiUrl'
  static Future<String> sendMultiModalMessage(
      String text,
      File image,
      ) async {
    try {
      final imageBytes = await image.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': text},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.4,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 4096,
        }
      });

      print('=== Gemini Vision API Request ===');

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'), // Ginamit ang tamang apiUrl
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return _handleApiResponse(response);
    } catch (e) {
      print('Network or File Exception: $e');
      return 'Error processing image: $e';
    }
  }

  // (Walang binago sa function na ito)
  static String _handleApiResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['candidates'] != null &&
          data['candidates'].isNotEmpty &&
          data['candidates'][0]['content'] != null &&
          data['candidates'][0]['content']['parts'] != null &&
          data['candidates'][0]['content']['parts'].isNotEmpty) {
        final responseText =
        data['candidates'][0]['content']['parts'][0]['text'];
        print('Successfully received response.');
        return responseText;
      } else if (data['promptFeedback'] != null) {
        final blockReason = data['promptFeedback']['blockReason'];
        print('Prompt was blocked. Reason: $blockReason');
        return 'The request was blocked due to safety settings. Reason: $blockReason';
      } else {
        print('Invalid response structure: ${jsonEncode(data)}');
        return 'Error: Invalid response from Gemini API.';
      }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['error']['message'] ?? 'Unknown API Error';
        print('API Error: $errorMessage');
        return 'Error: ${response.statusCode} - $errorMessage';
      } catch (e) {
        print('Raw Error Response: ${response.body}');
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    }
  }
}
