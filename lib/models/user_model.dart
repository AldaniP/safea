import 'dart:convert';

class User {
  final String id;
  final String displayName;
  final int totalPoints;
  final int level;
  final String? currentRoadmapId;

  User({
    required this.id,
    required this.displayName,
    this.totalPoints = 0,
    this.level = 1,
    this.currentRoadmapId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'totalPoints': totalPoints,
      'level': level,
      'currentRoadmapId': currentRoadmapId,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      displayName: map['displayName'] ?? '',
      totalPoints: map['totalPoints'] ?? 0,
      level: map['level'] ?? 1,
      currentRoadmapId: map['currentRoadmapId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? displayName,
    int? totalPoints,
    int? level,
    String? currentRoadmapId,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      currentRoadmapId: currentRoadmapId ?? this.currentRoadmapId,
    );
  }
}
