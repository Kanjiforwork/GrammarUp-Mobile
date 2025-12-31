class UserAchievementModel {
  final String id;
  final String oderId;
  final String achievementId;
  final DateTime earnedAt;

  UserAchievementModel({
    required this.id,
    required this.oderId,
    required this.achievementId,
    required this.earnedAt,
  });

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementModel(
      id: json['id'] as String,
      oderId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      earnedAt: DateTime.parse(json['earned_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': oderId,
      'achievement_id': achievementId,
      'earned_at': earnedAt.toIso8601String(),
    };
  }
}

// Model kết hợp achievement và trạng thái earned của user
class UserAchievementWithDetails {
  final UserAchievementModel? userAchievement;
  final String achievementId;
  final String name;
  final String description;
  final String? iconUrl;
  final String? category;
  final Map<String, dynamic> criteria;
  final int pointsReward;

  UserAchievementWithDetails({
    this.userAchievement,
    required this.achievementId,
    required this.name,
    required this.description,
    this.iconUrl,
    this.category,
    required this.criteria,
    required this.pointsReward,
  });

  bool get isEarned => userAchievement != null;
  DateTime? get earnedAt => userAchievement?.earnedAt;
}
