class AchievementModel {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final String? category;
  final Map<String, dynamic> criteria; // JSON criteria for unlocking
  final int pointsReward;
  final DateTime createdAt;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    this.category,
    required this.criteria,
    this.pointsReward = 0,
    required this.createdAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['icon_url'] as String?,
      category: json['category'] as String?,
      criteria: json['criteria'] as Map<String, dynamic>? ?? {},
      pointsReward: json['points_reward'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'category': category,
      'criteria': criteria,
      'points_reward': pointsReward,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper to get criteria value
  int? getCriteriaValue(String key) {
    return criteria[key] as int?;
  }

  String get categoryLabel {
    switch (category) {
      case 'learning':
        return 'Học tập';
      case 'streak':
        return 'Chuỗi ngày';
      case 'exercise':
        return 'Bài tập';
      case 'vocabulary':
        return 'Từ vựng';
      case 'milestone':
        return 'Cột mốc';
      default:
        return category ?? 'Khác';
    }
  }
}
