import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_history_service.dart';
import '../services/gemini_service.dart';
import '../widgets/input_bar.dart';
import '../widgets/message_bubble.dart';

class HistoryScreen extends StatefulWidget {
  final String topic;

  const HistoryScreen({super.key, required this.topic});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ChatHistoryService _chatHistoryService = ChatHistoryService();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await _chatHistoryService.getHistory(widget.topic);
    setState(() {
      _messages = history;
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend(String text) async {
    final userMessage = ChatMessage(
      text: text,
      role: 'user',
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final instruction = 'You are an expert on "${widget.topic}". Answer questions STRICTLY related to this topic. If the question is not about "${widget.topic}", politely decline and state that you can only answer questions about ${widget.topic}.';
      final promptedText = '$instruction\n\nQuestion: $text';
      final aiResponse = await GeminiService.sendMultiTurnMessage(_messages, promptedText);
      final modelMessage = ChatMessage(
        text: aiResponse,
        role: 'model',
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(modelMessage);
      });
      await _chatHistoryService.saveHistory(widget.topic, _messages);
    } catch (e) {
      final errorMessage = ChatMessage(
        text: 'Error: $e',
        role: 'model',
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(errorMessage);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic} History'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('No history found for this topic.'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return MessageBubble(message: msg);
                        },
                      ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 12),
                  Text('Thinking...'),
                ],
              ),
            ),
          InputBar(onSendMessage: _handleSend),
        ],
      ),
    );
  }
}
