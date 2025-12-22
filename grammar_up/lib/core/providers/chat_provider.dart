import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_openai/dart_openai.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'] as String,
    isUser: json['isUser'] as bool,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

class ChatProvider extends ChangeNotifier {
  static const String _messagesKey = 'chat_messages';
  static const String _chatHistoryKey = 'chat_history';
  
  final List<ChatMessage> _messages = [];
  final List<OpenAIChatCompletionChoiceMessageModel> _chatHistory = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<OpenAIChatCompletionChoiceMessageModel> get chatHistory => _chatHistory;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  ChatProvider() {
    _initializeChatHistory();
    _loadMessages();
  }

  void _initializeChatHistory() {
    // Add system message for grammar assistant if not exists
    if (_chatHistory.isEmpty) {
      _chatHistory.add(
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              '''You are an English Tutor AI assistant. Your role is STRICTLY limited to helping users with English language learning ONLY.

You can help with:
- English grammar explanations and corrections
- Vocabulary and word meanings
- Pronunciation guidance
- Sentence structure and writing
- Reading comprehension
- English conversation practice
- IELTS, TOEFL, TOEIC preparation
- Common English mistakes and how to fix them

IMPORTANT RULES:
1. ONLY answer questions related to English language learning
2. If a user asks about anything NOT related to English (like math, science, coding, history, etc.), politely decline and remind them that you are an English tutor only
3. Always respond in a friendly and encouraging manner
4. Provide examples when explaining grammar rules
5. If the user writes in another language, you can help translate it to English and explain the grammar

Example response for off-topic questions:
"I'm sorry, but I'm an English Tutor assistant and can only help with English language learning. If you have any questions about grammar, vocabulary, pronunciation, or any other English-related topics, I'd be happy to help!"''',
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);
      
      if (messagesJson != null) {
        final List<dynamic> decoded = jsonDecode(messagesJson);
        _messages.clear();
        _messages.addAll(
          decoded.map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
        );
        
        // Rebuild chat history from messages
        for (var message in _messages) {
          _chatHistory.add(
            OpenAIChatCompletionChoiceMessageModel(
              role: message.isUser ? OpenAIChatMessageRole.user : OpenAIChatMessageRole.assistant,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(message.text),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading chat messages: $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(_messages.map((m) => m.toJson()).toList());
      await prefs.setString(_messagesKey, messagesJson);
    } catch (e) {
      print('Error saving chat messages: $e');
    }
  }

  void addUserMessage(String text) {
    final message = ChatMessage(text: text, isUser: true);
    _messages.add(message);
    
    _chatHistory.add(
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(text),
        ],
      ),
    );
    
    _saveMessages();
    notifyListeners();
  }

  void addAssistantMessage(String text) {
    final message = ChatMessage(text: text, isUser: false);
    _messages.add(message);
    
    _chatHistory.add(
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.assistant,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(text),
        ],
      ),
    );
    
    _saveMessages();
    notifyListeners();
  }

  void removeLastUserMessage() {
    if (_messages.isNotEmpty && _messages.last.isUser) {
      _messages.removeLast();
    }
    if (_chatHistory.isNotEmpty && _chatHistory.last.role == OpenAIChatMessageRole.user) {
      _chatHistory.removeLast();
    }
    _saveMessages();
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> clearChat() async {
    _messages.clear();
    _chatHistory.clear();
    _initializeChatHistory();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_messagesKey);
    
    notifyListeners();
  }
}
