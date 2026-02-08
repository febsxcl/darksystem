import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = _getBubbleColor(context, isDarkMode);
    final textColor = _getTextColor(context, isDarkMode);

    return Align(
      alignment: message.isUserMessage
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null)
              Image.file(
                File(message.imageUrl!),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            if (message.imageUrl != null) const SizedBox(height: 8),
            MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: textColor, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBubbleColor(BuildContext context, bool isDarkMode) {
    if (message.isUserMessage) {
      return isDarkMode ? Colors.black : Colors.white;
    }
    return isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
  }

  Color _getTextColor(BuildContext context, bool isDarkMode) {
    if (message.isUserMessage) {
      return isDarkMode ? Colors.white : Colors.black;
    }
    return isDarkMode ? Colors.white : Colors.black;
  }
}
