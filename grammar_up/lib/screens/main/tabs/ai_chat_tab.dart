import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_keys.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../widgets/common/dolphin_mascot.dart';
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
    OpenAI.apiKey = ApiKeys.openAiKey;
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
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final userMessage = _messageController.text;
    _messageController.clear();

    _soundService.setSoundEnabled(settingsProvider.soundEffects);
    _soundService.playMessageSent();

    chatProvider.addUserMessage(userMessage);
    chatProvider.setLoading(true);
    _scrollToBottom();

    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo',
        messages: chatProvider.chatHistory,
        temperature: 0.7,
        maxTokens: 500,
      );

      final responseText =
          chatCompletion.choices.first.message.content?.first.text ??
              'Sorry, I could not generate a response.';

      if (mounted) {
        chatProvider.addAssistantMessage(responseText);
        chatProvider.setLoading(false);

        _soundService.setSoundEnabled(settingsProvider.soundEffects);
        _soundService.playMessageReceived();

        _scrollToBottom();
      }
    } catch (e) {
      chatProvider.removeLastUserMessage();

      if (mounted) {
        String errorMessage = 'Sorry, I encountered an error. ';

        if (e.toString().contains('Failed to fetch') ||
            e.toString().contains('ClientException')) {
          errorMessage += 'This might be due to:\n'
              '• CORS restriction when running on web\n'
              '• Invalid API key\n'
              '• Network connection issue\n\n'
              'Try running the app on mobile or desktop instead of web browser.';
        } else if (e.toString().contains('401') ||
            e.toString().contains('Unauthorized')) {
          errorMessage +=
              'The API key appears to be invalid or expired. Please check your OpenAI API key.';
        } else {
          errorMessage += e.toString();
        }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n?.clearChat ?? 'Clear Chat',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
          ),
        ),
        content: Text(
          l10n?.clearChatConfirm ??
              'Are you sure you want to clear the chat history?',
          style: GoogleFonts.nunito(
            color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).clearChat();
              Navigator.pop(context);
            },
            child: Text(
              l10n?.confirm ?? 'Confirm',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final messages = chatProvider.messages;
        final isLoading = chatProvider.isLoading;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.gray50,
          appBar: AppBar(
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.white,
            elevation: 0,
            centerTitle: false,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n?.aiAssistant ?? 'AI Assistant',
                  style: GoogleFonts.nunito(
                    color:
                        isDark ? AppColors.darkTextPrimary : AppColors.gray900,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            actions: [
              if (messages.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color:
                        isDark ? AppColors.darkTextSecondary : AppColors.gray600,
                  ),
                  onPressed: _showClearChatDialog,
                  tooltip: l10n?.clearChat ?? 'Clear Chat',
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyState(context, l10n)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length && isLoading) {
                            return _buildTypingIndicator(context, l10n);
                          }
                          final message = messages[index];
                          return ChatBubble(message: message);
                        },
                      ),
              ),
              _buildInputArea(context, l10n, isLoading, primaryColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations? l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DolphinMascot(
              size: 140,
              mood: MascotMood.happy,
              animate: true,
            ),
            const SizedBox(height: 32),
            Text(
              l10n?.aiGrammarAssistant ?? 'AI Grammar Assistant',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.askAboutGrammar ??
                  'Ask me anything about English grammar!\nI\'m here to help you learn.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Quick suggestions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip(
                    'What is a verb?', primaryColor, isDark),
                _buildSuggestionChip(
                    'Past vs Present tense', primaryColor, isDark),
                _buildSuggestionChip(
                    'When to use "the"?', primaryColor, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text, Color color, bool isDark) {
    return GestureDetector(
      onTap: () {
        _messageController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context, AppLocalizations? l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DolphinAvatar(size: 36),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.gray200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n?.aiThinking ?? 'Thinking...',
                  style: GoogleFonts.nunito(
                    color:
                        isDark ? AppColors.darkTextSecondary : AppColors.gray600,
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

  Widget _buildInputArea(BuildContext context, AppLocalizations? l10n,
      bool isLoading, Color primaryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.gray50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.gray200,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color:
                        isDark ? AppColors.darkTextPrimary : AppColors.gray900,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n?.askGrammarHint ?? 'Ask about grammar...',
                    hintStyle: GoogleFonts.nunito(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.gray500,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !isLoading,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Send button with 3D effect
            GestureDetector(
              onTap: isLoading ? null : _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLoading ? AppColors.gray400 : primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: primaryColor.withAlpha(128),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const DolphinAvatar(size: 36),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? primaryColor
                    : (isDark ? AppColors.darkSurface : AppColors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 18),
                ),
                border: message.isUser
                    ? null
                    : Border.all(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.gray200,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black12 : AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: GoogleFonts.nunito(
                  color: message.isUser
                      ? AppColors.white
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.gray900),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
