import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vocabulary.dart';
import '../core/services/supabase_service.dart';
import '../core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VocabularyService {
  static const String _apiUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';
  static const String _translateUrl = 'https://api.mymemory.translated.net/get';

  final SupabaseClient _supabase = SupabaseService.client;
  final _log = AppLogger('VocabularyService');

  Future<String?> _translateToVietnamese(String text) async {
    try {
      final url = Uri.parse('$_translateUrl?q=${Uri.encodeComponent(text)}&langpair=en|vi');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['responseData'] != null) {
          return data['responseData']['translatedText'] as String?;
        }
      }
      return null;
    } catch (e) {
      _log.error('Error translating', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> lookupWord(String word) async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/$word'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final wordData = data[0];
          final phonetic = wordData['phonetic'] ?? '';

          final meanings = wordData['meanings'] as List<dynamic>;
          if (meanings.isNotEmpty) {
            final firstMeaning = meanings[0];
            final partOfSpeech = firstMeaning['partOfSpeech'] ?? '';
            final definitions = firstMeaning['definitions'] as List<dynamic>;

            if (definitions.isNotEmpty) {
              final definition = definitions[0]['definition'] ?? '';
              final example = definitions[0]['example'] ?? '';

              final vietnameseTranslation = await _translateToVietnamese(definition);

              return {
                'word': word,
                'phonetic': phonetic,
                'part_of_speech': partOfSpeech,
                'definition': definition,
                'example_sentence': example.isNotEmpty ? example : null,
                'translation': vietnameseTranslation != null ? {'vi': vietnameseTranslation} : null,
              };
            }
          }
        }
      }
      return null;
    } catch (e) {
      _log.error('Error looking up word', e);
      return null;
    }
  }

  Future<List<Vocabulary>> getSavedVocabulary() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _log.warning('No user logged in');
        return [];
      }

      final response = await _supabase
          .from('vocabulary')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Vocabulary.fromJson(json))
          .toList();
    } catch (e) {
      _log.error('Error fetching vocabulary', e);
      return [];
    }
  }

  Future<Vocabulary?> saveVocabulary(Map<String, dynamic> vocabData) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _log.error('No user logged in, cannot save vocabulary');
        return null;
      }

      final vocab = Vocabulary(
        id: '',
        userId: userId,
        word: vocabData['word'] as String,
        phonetic: vocabData['phonetic'] as String?,
        partOfSpeech: vocabData['part_of_speech'] as String?,
        definition: vocabData['definition'] as String,
        exampleSentence: vocabData['example_sentence'] as String?,
        translation: vocabData['translation'] != null
            ? Map<String, String>.from(vocabData['translation'])
            : null,
        difficultyLevel: vocabData['difficulty_level'] as String?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _log.debug('Saving vocabulary: ${vocab.word}');

      final response = await _supabase
          .from('vocabulary')
          .insert(vocab.toInsertJson())
          .select()
          .single();

      _log.success('Vocabulary saved successfully');
      return Vocabulary.fromJson(response);
    } catch (e) {
      _log.error('Error saving vocabulary', e);
      if (e.toString().contains('duplicate') || e.toString().contains('unique')) {
        _log.warning('Word already exists in vocabulary');
      }
      return null;
    }
  }

  Future<bool> deleteVocabulary(String vocabularyId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from('vocabulary')
          .delete()
          .eq('id', vocabularyId)
          .eq('user_id', userId);

      _log.success('Vocabulary deleted successfully');
      return true;
    } catch (e) {
      _log.error('Error deleting vocabulary', e);
      return false;
    }
  }

  Future<bool> toggleMastered(String vocabularyId, bool isMastered) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from('vocabulary')
          .update({'is_mastered': isMastered})
          .eq('id', vocabularyId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      _log.error('Error updating mastered status', e);
      return false;
    }
  }

  Future<bool> recordReview(String vocabularyId, bool isCorrect) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.rpc('increment_review_count', params: {
        'vocab_id': vocabularyId,
      });

      await _supabase.from('vocabulary_reviews').insert({
        'user_id': userId,
        'vocabulary_id': vocabularyId,
        'is_correct': isCorrect,
        'review_type': 'flashcard',
      });

      return true;
    } catch (e) {
      _log.error('Error recording review', e);
      return false;
    }
  }
}
