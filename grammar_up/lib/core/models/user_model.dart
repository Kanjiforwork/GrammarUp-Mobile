class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String nativeLanguage;
  final String level;
  final int learningStreak;
  final int totalPoints;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.nativeLanguage = 'vi',
    this.level = 'beginner',
    this.learningStreak = 0,
    this.totalPoints = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      nativeLanguage: json['native_language'] as String? ?? 'vi',
      level: json['level'] as String? ?? 'beginner',
      learningStreak: json['learning_streak'] as int? ?? 0,
      totalPoints: json['total_points'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'native_language': nativeLanguage,
      'level': level,
      'learning_streak': learningStreak,
      'total_points': totalPoints,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? nativeLanguage,
    String? level,
    int? learningStreak,
    int? totalPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      level: level ?? this.level,
      learningStreak: learningStreak ?? this.learningStreak,
      totalPoints: totalPoints ?? this.totalPoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
