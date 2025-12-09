import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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
  
  List<Map<String, dynamic>> _savedWords = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
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
        setState(() {
          _savedWords.insert(0, result);
          _isLoading = false;
          _wordController.clear();
        });
        
        // Lưu vào database (sẽ kết nối Supabase sau)
        await _vocabService.saveVocabulary(result);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm từ "$word" vào sổ từ vựng'),
              backgroundColor: AppColors.success,
            ),
          );
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

  void _navigateToFlashcards() {
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
      backgroundColor: AppColors.background,
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
                color: Colors.white,
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
                      decoration: const InputDecoration(
                        hintText: 'Nhập từ vựng tiếng Anh...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            child: _savedWords.isEmpty
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
                      final word = _savedWords[index];
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
                                          word['word'] ?? '',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        if (word['phonetic'] != null && word['phonetic'].isNotEmpty)
                                          Text(
                                            word['phonetic'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                                    onPressed: () {
                                      setState(() {
                                        _savedWords.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (word['part_of_speech'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    word['part_of_speech'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Text(
                                word['definition'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              // Nghĩa tiếng Việt
                              if (word['translation'] != null && word['translation']['vi'] != null) ...[
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
                                          word['translation']['vi'],
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (word['example_sentence'] != null && word['example_sentence'].isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.format_quote, size: 16, color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          word['example_sentence'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
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
  final List<Map<String, dynamic>> words;

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
                                currentWord['word'] ?? '',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (currentWord['phonetic'] != null && currentWord['phonetic'].isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  currentWord['phonetic'],
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
                              if (currentWord['part_of_speech'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    currentWord['part_of_speech'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              Text(
                                currentWord['definition'] ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              // Nghĩa tiếng Việt trong flashcard
                              if (currentWord['translation'] != null && currentWord['translation']['vi'] != null) ...[
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
                                          currentWord['translation']['vi'],
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
                              if (currentWord['example_sentence'] != null && currentWord['example_sentence'].isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '"${currentWord['example_sentence']}"',
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
