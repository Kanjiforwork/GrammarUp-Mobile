import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_keys.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:dart_openai/dart_openai.dart';

class AIChatTab extends StatefulWidget {
  const AIChatTab({super.key});

  @override
  State<AIChatTab> createState() => _AIChatTabState();
}

class _AIChatTabState extends State<AIChatTab> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    // Initialize OpenAI
    OpenAI.apiKey = ApiKeys.openAiKey;
    // Add system message for grammar assistant
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final userMessage = _messageController.text;
    _messageController.clear();

    // Play send sound
    _soundService.setSoundEnabled(settingsProvider.soundEffects);
    _soundService.playMessageSent();

    chatProvider.addUserMessage(userMessage);
    chatProvider.setLoading(true);
    _scrollToBottom();

    try {
      // Send request to OpenAI
      final chatCompletion = await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo',
        messages: chatProvider.chatHistory,
        temperature: 0.7,
        maxTokens: 500,
      );

      final responseText = chatCompletion.choices.first.message.content?.first.text ?? 
                          'Sorry, I could not generate a response.';

      if (mounted) {
        chatProvider.addAssistantMessage(responseText);
        chatProvider.setLoading(false);
        
        // Play receive sound
        _soundService.setSoundEnabled(settingsProvider.soundEffects);
        _soundService.playMessageReceived();
        
        _scrollToBottom();
      }
    } catch (e) {
      // Remove the failed user message from history
      chatProvider.removeLastUserMessage();
      
      if (mounted) {
        String errorMessage = 'Sorry, I encountered an error. ';
        
        if (e.toString().contains('Failed to fetch') || e.toString().contains('ClientException')) {
          errorMessage += 'This might be due to:\n'
              '• CORS restriction when running on web\n'
              '• Invalid API key\n'
              '• Network connection issue\n\n'
              'Try running the app on mobile or desktop instead of web browser.';
        } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          errorMessage += 'The API key appears to be invalid or expired. Please check your OpenAI API key.';
        } else {
          errorMessage += e.toString();
        }
        
        // Play error sound
        _soundService.setSoundEnabled(settingsProvider.soundEffects);
        _soundService.playError();
        
        chatProvider.addAssistantMessage(errorMessage);
        chatProvider.setLoading(false);
        _scrollToBottom();
      }
    }
  }

  void _showClearChatDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.clearChat ?? 'Clear Chat'),
        content: Text(l10n?.clearChatConfirm ?? 'Are you sure you want to clear the chat history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).clearChat();
              Navigator.pop(context);
            },
            child: Text(l10n?.confirm ?? 'Confirm', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final messages = chatProvider.messages;
        final isLoading = chatProvider.isLoading;
        
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.smart_toy, color: Colors.white),
                const SizedBox(width: 8),
                Text(l10n?.aiAssistant ?? 'AI Chat Assistant'),
              ],
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              if (messages.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _showClearChatDialog,
                  tooltip: l10n?.clearChat ?? 'Clear Chat',
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.smart_toy,
                                size: 64,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n?.aiGrammarAssistant ?? 'AI Grammar Assistant',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                l10n?.askAboutGrammar ?? 'Ask me anything about English grammar!\nI\'m here to help you learn.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length && isLoading) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.smart_toy, color: AppColors.primary, size: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n?.aiThinking ?? 'AI is thinking...',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          final message = messages[index];
                          return ChatBubble(message: message);
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: l10n?.askGrammarHint ?? 'Ask about grammar...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: AppColors.divider),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: AppColors.divider),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: AppColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _sendMessage(),
                          enabled: !isLoading,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isLoading ? AppColors.textSecondary : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: isLoading ? null : _sendMessage,
                          icon: const Icon(Icons.send, color: Colors.white),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.primary
                    : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
