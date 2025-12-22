import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'app_name': 'Grammar Up',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'done': 'Done',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      
      // Navigation
      'lesson': 'Lesson',
      'exercise': 'Exercise',
      'ai_chat': 'AI Chat',
      'vocabulary': 'Vocabulary',
      'account': 'Account',
      'settings': 'Settings',
      
      // Settings
      'account_section': 'Account',
      'edit_profile': 'Edit Profile',
      'change_password': 'Change Password',
      'notifications': 'Notifications',
      'preferences_section': 'Preferences',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'sound_effects': 'Sound Effects',
      'support_section': 'Support',
      'help_center': 'Help Center',
      'about': 'About',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'log_out': 'Log Out',
      'log_out_confirm': 'Are you sure you want to log out?',
      'version': 'Version',
      
      // AI Chat
      'ai_assistant': 'AI Chat Assistant',
      'ai_grammar_assistant': 'AI Grammar Assistant',
      'ask_about_grammar': 'Ask me anything about English grammar!\nI\'m here to help you learn.',
      'ask_grammar_hint': 'Ask about grammar...',
      'ai_thinking': 'AI is thinking...',
      'clear_chat': 'Clear Chat',
      'clear_chat_confirm': 'Are you sure you want to clear the chat history?',
      
      // Lessons
      'lessons_title': 'Lessons',
      'start_lesson': 'Start Lesson',
      'continue_lesson': 'Continue',
      'completed': 'Completed',
      
      // Exercises
      'exercises_title': 'Exercises',
      'start_exercise': 'Start',
      'questions': 'questions',
      
      // Vocabulary
      'vocabulary_title': 'Vocabulary',
      'add_word': 'Add Word',
      'search_words': 'Search words...',
      
      // Language selection
      'select_language': 'Select Language',
      'english': 'English',
      'vietnamese': 'Tiếng Việt',
    },
    'vi': {
      // General
      'app_name': 'Grammar Up',
      'cancel': 'Hủy',
      'confirm': 'Xác nhận',
      'save': 'Lưu',
      'delete': 'Xóa',
      'edit': 'Chỉnh sửa',
      'done': 'Xong',
      'loading': 'Đang tải...',
      'error': 'Lỗi',
      'success': 'Thành công',
      
      // Navigation
      'lesson': 'Bài học',
      'exercise': 'Bài tập',
      'ai_chat': 'Trò chuyện AI',
      'vocabulary': 'Từ vựng',
      'account': 'Tài khoản',
      'settings': 'Cài đặt',
      
      // Settings
      'account_section': 'Tài khoản',
      'edit_profile': 'Chỉnh sửa hồ sơ',
      'change_password': 'Đổi mật khẩu',
      'notifications': 'Thông báo',
      'preferences_section': 'Tùy chỉnh',
      'language': 'Ngôn ngữ',
      'dark_mode': 'Chế độ tối',
      'sound_effects': 'Hiệu ứng âm thanh',
      'support_section': 'Hỗ trợ',
      'help_center': 'Trung tâm trợ giúp',
      'about': 'Về ứng dụng',
      'privacy_policy': 'Chính sách bảo mật',
      'terms_of_service': 'Điều khoản dịch vụ',
      'log_out': 'Đăng xuất',
      'log_out_confirm': 'Bạn có chắc chắn muốn đăng xuất?',
      'version': 'Phiên bản',
      
      // AI Chat
      'ai_assistant': 'Trợ lý AI',
      'ai_grammar_assistant': 'Trợ lý ngữ pháp AI',
      'ask_about_grammar': 'Hỏi tôi bất cứ điều gì về ngữ pháp tiếng Anh!\nTôi ở đây để giúp bạn học.',
      'ask_grammar_hint': 'Hỏi về ngữ pháp...',
      'ai_thinking': 'AI đang suy nghĩ...',
      'clear_chat': 'Xóa cuộc trò chuyện',
      'clear_chat_confirm': 'Bạn có chắc chắn muốn xóa lịch sử trò chuyện?',
      
      // Lessons
      'lessons_title': 'Bài học',
      'start_lesson': 'Bắt đầu',
      'continue_lesson': 'Tiếp tục',
      'completed': 'Hoàn thành',
      
      // Exercises
      'exercises_title': 'Bài tập',
      'start_exercise': 'Bắt đầu',
      'questions': 'câu hỏi',
      
      // Vocabulary
      'vocabulary_title': 'Từ vựng',
      'add_word': 'Thêm từ',
      'search_words': 'Tìm kiếm từ...',
      
      // Language selection
      'select_language': 'Chọn ngôn ngữ',
      'english': 'English',
      'vietnamese': 'Tiếng Việt',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']?[key] ?? 
           key;
  }

  // Getters for common translations
  String get appName => translate('app_name');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get done => translate('done');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  
  // Navigation
  String get lesson => translate('lesson');
  String get exercise => translate('exercise');
  String get aiChat => translate('ai_chat');
  String get vocabulary => translate('vocabulary');
  String get account => translate('account');
  String get settings => translate('settings');
  
  // Settings
  String get accountSection => translate('account_section');
  String get editProfile => translate('edit_profile');
  String get changePassword => translate('change_password');
  String get notifications => translate('notifications');
  String get preferencesSection => translate('preferences_section');
  String get language => translate('language');
  String get darkMode => translate('dark_mode');
  String get soundEffects => translate('sound_effects');
  String get supportSection => translate('support_section');
  String get helpCenter => translate('help_center');
  String get about => translate('about');
  String get privacyPolicy => translate('privacy_policy');
  String get termsOfService => translate('terms_of_service');
  String get logOut => translate('log_out');
  String get logOutConfirm => translate('log_out_confirm');
  String get version => translate('version');
  
  // AI Chat
  String get aiAssistant => translate('ai_assistant');
  String get aiGrammarAssistant => translate('ai_grammar_assistant');
  String get askAboutGrammar => translate('ask_about_grammar');
  String get askGrammarHint => translate('ask_grammar_hint');
  String get aiThinking => translate('ai_thinking');
  String get clearChat => translate('clear_chat');
  String get clearChatConfirm => translate('clear_chat_confirm');
  
  // Language selection
  String get selectLanguage => translate('select_language');
  String get english => translate('english');
  String get vietnamese => translate('vietnamese');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
