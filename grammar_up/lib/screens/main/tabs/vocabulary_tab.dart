import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../services/vocabulary_service.dart';
import '../../../models/vocabulary.dart';

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
      print('Error loading saved words: $e');
    }
  }

  Future<void> _lookupAndAddWord() async {
    final word = _wordController.text.trim();
    if (word.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập từ vựng';
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
        // Lưu vào Supabase
        final savedVocab = await _vocabService.saveVocabulary(result);
        
        if (savedVocab != null) {
          final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
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
                content: Text('Đã thêm từ "$word" vào sổ từ vựng'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } else {
          final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
          _soundService.setSoundEnabled(settingsProvider.soundEffects);
          _soundService.playError();
          
          setState(() {
            _isLoading = false;
            _errorMessage = 'Không thể lưu từ vựng. Từ này có thể đã tồn tại.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không tìm thấy từ "$word". Vui lòng thử lại.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Có lỗi xảy ra. Vui lòng kiểm tra kết nối mạng.';
      });
    }
  }

  Future<void> _deleteWord(Vocabulary vocab) async {
    final success = await _vocabService.deleteVocabulary(vocab.id);
    if (success) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      _soundService.setSoundEnabled(settingsProvider.soundEffects);
      _soundService.playClick();
      
      setState(() {
        _savedWords.removeWhere((v) => v.id == vocab.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa từ "${vocab.word}"'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _navigateToFlashcards() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _soundService.setSoundEnabled(settingsProvider.soundEffects);
    _soundService.playClick();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(words: _savedWords),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Sổ Từ Vựng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          if (_savedWords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.style, color: Colors.white),
              onPressed: _navigateToFlashcards,
              tooltip: 'Học Flashcard',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1A1A1A)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wordController,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập từ vựng tiếng Anh...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF808080)
                              : AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (_) => _lookupAndAddWord(),
                    ),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.add_circle, color: AppColors.primary, size: 32),
                      onPressed: _lookupAndAddWord,
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
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),

          // Word List
          Expanded(
            child: _isLoadingWords
                ? const Center(child: CircularProgressIndicator())
                : _savedWords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book_outlined, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có từ vựng nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nhập từ tiếng Anh để AI tra nghĩa tự động',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _savedWords.length,
                    itemBuilder: (context, index) {
                      final vocab = _savedWords[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vocab.word,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        if (vocab.phonetic != null && vocab.phonetic!.isNotEmpty)
                                          Text(
                                            vocab.phonetic!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? const Color(0xFFB0B0B0)
                                                  : AppColors.textSecondary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                                    onPressed: () => _deleteWord(vocab),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (vocab.partOfSpeech != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    vocab.partOfSpeech!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Text(
                                vocab.definition,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              // Nghĩa tiếng Việt
                              if (vocab.translation != null && vocab.translation!['vi'] != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.translate, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          vocab.translation!['vi']!,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (vocab.exampleSentence != null && vocab.exampleSentence!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFF2A2A2A)
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.format_quote,
                                        size: 16,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? const Color(0xFFB0B0B0)
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          vocab.exampleSentence!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? const Color(0xFFB0B0B0)
                                                : AppColors.textSecondary,
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
                    },
                  ),
          ),
        ],
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
    if (widget.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('Flashcard', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text('Không có từ vựng để học'),
        ),
      );
    }

    final currentWord = widget.words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Flashcard (${_currentIndex + 1}/${widget.words.length})',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
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
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (currentWord.phonetic != null && currentWord.phonetic!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  currentWord.phonetic!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              Icon(Icons.touch_app, size: 40, color: AppColors.textSecondary.withOpacity(0.3)),
                              const SizedBox(height: 8),
                              Text(
                                'Chạm để xem nghĩa',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                ),
                              ),
                            ] else ...[
                              if (currentWord.partOfSpeech != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    currentWord.partOfSpeech!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              Text(
                                currentWord.definition,
                                style: const TextStyle(
                                  fontSize: 20,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              // Nghĩa tiếng Việt trong flashcard
                              if (currentWord.translation != null && currentWord.translation!['vi'] != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.translate, size: 18, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          currentWord.translation!['vi']!,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (currentWord.exampleSentence != null && currentWord.exampleSentence!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '"${currentWord.exampleSentence}"',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 48,
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: _currentIndex > 0 ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
                    ),
                    onPressed: _currentIndex > 0 ? _previousCard : null,
                  ),
                  IconButton(
                    iconSize: 48,
                    icon: Icon(Icons.flip, color: AppColors.primary),
                    onPressed: _flipCard,
                  ),
                  IconButton(
                    iconSize: 48,
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _currentIndex < widget.words.length - 1
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.3),
                    ),
                    onPressed: _currentIndex < widget.words.length - 1 ? _nextCard : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
