import 'dart:io';

class ChatMessage {
  final String text;
  final String role;
  final DateTime timestamp;
  final File? imageFile;
  final String? imageUrl;

  ChatMessage({
    required this.text,
    required this.role,
    required this.timestamp,
    this.imageFile,
    this.imageUrl,
  });

  // Helper: Is this a user message?
  bool get isUserMessage => role == "user";

 Map<String, dynamic> toJson() => {
    'text': text,
    'role': role,
    'timestamp': timestamp.toIso8601String(),
    'imageUrl': imageUrl,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'] as String,
    role: json['role'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    imageUrl: json['imageUrl'] as String?,
  );
}
