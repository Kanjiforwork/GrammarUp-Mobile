import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../services/vocabulary_service.dart';
import '../../../models/vocabulary.dart';
import '../../../widgets/common/dolphin_mascot.dart';

class VocabularyTab extends StatefulWidget {
  const VocabularyTab({super.key});

  @override
  State<VocabularyTab> createState() => _VocabularyTabState();
}

class _VocabularyTabState extends State<VocabularyTab> {
  final TextEditingController _wordController = TextEditingController();
  final VocabularyService _vocabService = VocabularyService();
  final SoundService _soundService = SoundService();

  List<Vocabulary> _savedWords = [];
  bool _isLoading = false;
  bool _isLoadingWords = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedWords();
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedWords() async {
    setState(() {
      _isLoadingWords = true;
    });

    try {
      final words = await _vocabService.getSavedVocabulary();
      setState(() {
        _savedWords = words;
        _isLoadingWords = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWords = false;
      });
      debugPrint('Error loading saved words: $e');
    }
  }

  Future<void> _lookupAndAddWord() async {
    final word = _wordController.text.trim();
    if (word.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a word';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _vocabService.lookupWord(word);

      if (result != null) {
        final savedVocab = await _vocabService.saveVocabulary(result);

        if (savedVocab != null) {
          if (!mounted) return;
          final settingsProvider =
              Provider.of<SettingsProvider>(context, listen: false);
          _soundService.setSoundEnabled(settingsProvider.soundEffects);
          _soundService.playSuccess();

          setState(() {
            _savedWords.insert(0, savedVocab);
            _isLoading = false;
            _wordController.clear();
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added "$word" to vocabulary'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        } else {
          if (!mounted) return;
          final settingsProvider =
              Provider.of<SettingsProvider>(context, listen: false);
          _soundService.setSoundEnabled(settingsProvider.soundEffects);
          _soundService.playError();

          setState(() {
            _isLoading = false;
            _errorMessage = 'Could not save word. It may already exist.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Word "$word" not found. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please check your connection.';
      });
    }
  }

  Future<void> _deleteWord(Vocabulary vocab) async {
    final success = await _vocabService.deleteVocabulary(vocab.id);
    if (success && mounted) {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      _soundService.setSoundEnabled(settingsProvider.soundEffects);
      _soundService.playClick();

      setState(() {
        _savedWords.removeWhere((v) => v.id == vocab.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${vocab.word}"'),
            backgroundColor: AppColors.gray600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _navigateToFlashcards() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    _soundService.setSoundEnabled(settingsProvider.soundEffects);
    _soundService.playClick();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FlashcardScreen(words: _savedWords),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Vocabulary',
          style: GoogleFonts.nunito(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (_savedWords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.style_rounded, color: AppColors.white),
              onPressed: _navigateToFlashcards,
              tooltip: 'Flashcards',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Container(
            color: primaryColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wordController,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.gray900,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter an English word...',
                        hintStyle: GoogleFonts.nunito(
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.gray500,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.gray500,
                        ),
                      ),
                      onSubmitted: (_) => _lookupAndAddWord(),
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_rounded,
                            color: AppColors.white),
                        onPressed: _lookupAndAddWord,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Error Message
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withAlpha(77)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.nunito(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.error, size: 20),
                    onPressed: () => setState(() => _errorMessage = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // Word List
          Expanded(
            child: _isLoadingWords
                ? Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 3,
                    ),
                  )
                : _savedWords.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: _loadSavedWords,
                        color: primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: _savedWords.length,
                          itemBuilder: (context, index) {
                            final vocab = _savedWords[index];
                            return _buildVocabCard(context, vocab);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DolphinMascot(
              size: 120,
              mood: MascotMood.curious,
            ),
            const SizedBox(height: 24),
            Text(
              'No vocabulary yet',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter an English word above to\nautomatically look up its meaning',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabCard(BuildContext context, Vocabulary vocab) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                vocab.word.isNotEmpty ? vocab.word[0].toUpperCase() : '?',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          title: Text(
            vocab.word,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
            ),
          ),
          subtitle: vocab.phonetic != null && vocab.phonetic!.isNotEmpty
              ? Text(
                  vocab.phonetic!,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color:
                        isDark ? AppColors.darkTextSecondary : AppColors.gray600,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : null,
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error.withAlpha(179),
            ),
            onPressed: () => _deleteWord(vocab),
          ),
          children: [
            // Part of speech badge
            if (vocab.partOfSpeech != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vocab.partOfSpeech!,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Definition
            Text(
              vocab.definition,
              style: GoogleFonts.nunito(
                fontSize: 15,
                height: 1.5,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              ),
            ),

            // Vietnamese translation
            if (vocab.translation != null &&
                vocab.translation!['vi'] != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withAlpha(51)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.translate_rounded,
                        size: 18, color: primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vocab.translation!['vi']!,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.gray900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Example sentence
            if (vocab.exampleSentence != null &&
                vocab.exampleSentence!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceHighlight
                      : AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.gray500,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vocab.exampleSentence!,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.gray600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Flashcard Screen
class FlashcardScreen extends StatefulWidget {
  final List<Vocabulary> words;

  const FlashcardScreen({super.key, required this.words});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _showDefinition = false;

  void _nextCard() {
    if (_currentIndex < widget.words.length - 1) {
      setState(() {
        _currentIndex++;
        _showDefinition = false;
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showDefinition = false;
      });
    }
  }

  void _flipCard() {
    setState(() {
      _showDefinition = !_showDefinition;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    if (widget.words.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.gray50,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.white,
          elevation: 0,
          title: Text(
            'Flashcards',
            style: GoogleFonts.nunito(
              color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              fontWeight: FontWeight.w800,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const DolphinMascot(
                size: 120,
                mood: MascotMood.thinking,
              ),
              const SizedBox(height: 24),
              Text(
                'No vocabulary to study',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? AppColors.darkTextPrimary : AppColors.gray900,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentWord = widget.words[_currentIndex];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
        elevation: 0,
        title: Text(
          'Flashcards',
          style: GoogleFonts.nunito(
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentIndex + 1} / ${widget.words.length}',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.words.length,
            backgroundColor:
                isDark ? AppColors.darkSurfaceHighlight : AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 4,
          ),

          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _flipCard,
                child: Container(
                  margin: const EdgeInsets.all(24),
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.gray200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : AppColors.shadow,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!_showDefinition) ...[
                            Text(
                              currentWord.word,
                              style: GoogleFonts.nunito(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (currentWord.phonetic != null &&
                                currentWord.phonetic!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                currentWord.phonetic!,
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.gray600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                            Icon(
                              Icons.touch_app_rounded,
                              size: 40,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.gray400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to see meaning',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.gray500,
                              ),
                            ),
                          ] else ...[
                            if (currentWord.partOfSpeech != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryColor.withAlpha(26),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  currentWord.partOfSpeech!,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            Text(
                              currentWord.definition,
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                height: 1.6,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.gray900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // Vietnamese translation
                            if (currentWord.translation != null &&
                                currentWord.translation!['vi'] != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: primaryColor.withAlpha(26),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: primaryColor.withAlpha(77)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.translate_rounded,
                                        size: 20, color: primaryColor),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        currentWord.translation!['vi']!,
                                        style: GoogleFonts.nunito(
                                          fontSize: 18,
                                          color: primaryColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (currentWord.exampleSentence != null &&
                                currentWord.exampleSentence!.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceHighlight
                                      : AppColors.gray50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '"${currentWord.exampleSentence}"',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.gray600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back_ios_rounded,
                  isEnabled: _currentIndex > 0,
                  onTap: _previousCard,
                  isDark: isDark,
                  primaryColor: primaryColor,
                ),
                _buildNavButton(
                  icon: Icons.flip_rounded,
                  isEnabled: true,
                  onTap: _flipCard,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  isMain: true,
                ),
                _buildNavButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  isEnabled: _currentIndex < widget.words.length - 1,
                  onTap: _nextCard,
                  isDark: isDark,
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
    bool isMain = false,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: isMain ? 64 : 56,
        height: isMain ? 64 : 56,
        decoration: BoxDecoration(
          color: isMain
              ? primaryColor
              : (isDark ? AppColors.darkSurface : AppColors.white),
          shape: BoxShape.circle,
          border: isMain
              ? null
              : Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.gray200,
                ),
          boxShadow: isMain
              ? [
                  BoxShadow(
                    color: primaryColor.withAlpha(128),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: isMain ? 28 : 24,
          color: isMain
              ? AppColors.white
              : (isEnabled
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.gray700)
                  : (isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.gray400)),
        ),
      ),
    );
  }
}
