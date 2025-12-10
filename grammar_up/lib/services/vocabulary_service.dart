import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/vocabulary.dart';

class VocabularyService {
  // Sử dụng Free Dictionary API
  static const String _apiUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';
  static const String _translateUrl = 'https://api.mymemory.translated.net/get';
  static const String _openAIUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String?> _generateExampleWithGPT(String word, String definition) async {
    try {
      // TODO: Move API key to secure backend
      // For now, GPT feature is disabled for security
      print('GPT feature disabled - API key should be stored securely');
      return null;
      
      /* Uncomment when using secure backend
      print('🤖 Calling GPT to generate example for "$word"...');
      
      final response = await http.post(
        Uri.parse(_openAIUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY_HERE',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful English teacher. Create a simple, natural example sentence using the given word.'
            },
            {
              'role': 'user',
              'content': 'Create one simple example sentence using the word "$word" with this meaning: $definition. Only return the sentence, nothing else.'
            }
          ],
          'max_tokens': 50,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final example = data['choices'][0]['message']['content'].toString().trim();
        print('✅ GPT generated example: $example');
        return example.replaceAll('"', '').replaceAll('\n', '');
      } else {
        print('❌ GPT API error: ${response.statusCode} - ${response.body}');
        return null;
      }
      */
    } catch (e) {
      print('❌ Error generating example with GPT: $e');
      return null;
    }
  }

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
      print('Error translating: $e');
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
          
          // Lấy nghĩa đầu tiên
          final meanings = wordData['meanings'] as List<dynamic>;
          if (meanings.isNotEmpty) {
            final firstMeaning = meanings[0];
            final partOfSpeech = firstMeaning['partOfSpeech'] ?? '';
            final definitions = firstMeaning['definitions'] as List<dynamic>;
            
            if (definitions.isNotEmpty) {
              final definition = definitions[0]['definition'] ?? '';
              var example = definitions[0]['example'] ?? '';
              
              // Nếu không có example từ API, dùng GPT generate
              if (example.isEmpty) {
                print('No example from API, generating with GPT...');
                final gptExample = await _generateExampleWithGPT(word, definition);
                if (gptExample != null && gptExample.isNotEmpty) {
                  example = gptExample;
                  print('Generated example: $example');
                }
              }
              
              // Dịch sang tiếng Việt
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
      print('Error looking up word: $e');
      return null;
    }
  }

  // Lưu từ vựng vào local storage (giả lập database)
  Future<List<Vocabulary>> getSavedVocabulary() async {
    // Trong thực tế, bạn sẽ kết nối với Supabase hoặc database thật
    // Hiện tại tôi sẽ trả về danh sách mẫu
    return [];
  }

  Future<void> saveVocabulary(Map<String, dynamic> vocabData) async {
    // Trong thực tế, lưu vào Supabase/PostgreSQL
    // Hiện tại chỉ in ra console
    print('Saving vocabulary: $vocabData');
  }
}
