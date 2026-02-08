import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chat_message.dart';
import '../services/chat_history_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  final String topic;

  const ChatScreen({super.key, required this.topic});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();
  final ChatHistoryService _chatHistoryService = ChatHistoryService();
  bool _isLoading = false;
  File? _image; // Ito ang magho-hold ng image na pinili ng user

  @override
  void initState() {
    super.initState();
    addMessage('Hello! Let\'s talk about ${widget.topic}.', 'model');
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveConversation() async {
    if (messages.length > 1) {
      final List<ChatMessage> historyToSave = List.from(messages);
      if (historyToSave.isNotEmpty && historyToSave.first.role == 'model') {
        historyToSave.removeAt(0);
      }

      if (historyToSave.isNotEmpty) {
        final existingHistory = await _chatHistoryService.getHistory(widget.topic);
        existingHistory.addAll(historyToSave);
        await _chatHistoryService.saveHistory(widget.topic, existingHistory);
      }
    }
  }

  // === SOLUSYON 1: Inayos ang addMessage para tumanggap ng File ===
  void addMessage(String text, String role, {File? imageFile, String? imageUrl}) {
    setState(() {
      messages.add(ChatMessage(
        text: text,
        role: role,
        timestamp: DateTime.now(),
        imageFile: imageFile, // Gamitin ang imageFile para sa user
        imageUrl: imageUrl,   // Gamitin ang imageUrl para sa AI
      ));
    });
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // === SOLUSYON 2: Inayos ang handleSend para gamitin ang tamang service ===
  Future<void> handleSend(String text) async {
    // Idagdag ang mensahe ng user sa UI
    addMessage(text, "user", imageFile: _image);
    setState(() => _isLoading = true);

    final apiHistory = List<ChatMessage>.from(messages);
    if (apiHistory.isNotEmpty) apiHistory.removeLast();

    if (apiHistory.isNotEmpty && apiHistory.first.role == 'model') {
      apiHistory.removeAt(0);
    }

    final instruction = 'You are an expert on "${widget.topic}". Answer questions STRICTLY related to this topic. If the question is not about "${widget.topic}", politely decline and state that you can only answer questions about ${widget.topic}.';
    final promptedText = '$instruction\n\nQuestion: $text';

    try {
      String aiResponse;

      // Titingnan kung may image na naka-attach
      if (_image != null) {
        // Kung may image, gamitin ang multimodal service
        print("Sending with image to MultiModal service...");
        aiResponse = await GeminiService.sendMultiModalMessage(
          promptedText,
          _image!, // Ipapasa ang image file
        );
      } else {
        // Kung text lang, gamitin ang dati
        print("Sending text-only to MultiTurn service...");
        aiResponse = await GeminiService.sendMultiTurnMessage(
          apiHistory,
          promptedText,
        );
      }

      addMessage(aiResponse, "model");

    } catch (e) {
      addMessage('Error: $e', "model");
    } finally {
      // I-reset ang state pagkatapos ng API call
      setState(() {
        _isLoading = false;
        _image = null; // Alisin ang image pagkatapos ipadala
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // === SOLUSYON 3: Pinalitan ang WillPopScope ng PopScope ===
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _saveConversation();
        if (mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.topic),
        ),
        body: Column(
          children: [
            // Preview ng image na ipapadala
            if (_image != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Image.file(_image!, height: 100),
                    Positioned(
                      top: -10,
                      right: -10,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, shadows: [Shadow(blurRadius: 2.0)]),
                        onPressed: () {
                          setState(() {
                            _image = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: messages.isEmpty
                  ? const Center(child: Text('Start chatting!'))
                  : ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
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
            InputBar(
              onSendMessage: handleSend,
              onPickImage: _pickImage,
            ),
          ],
        ),
      ),
    );
  }
}
