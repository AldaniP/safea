import 'dart:convert';

enum ActivityType { breathing, meditation, exercise }

class Activity {
  final String id;
  final String title;
  final int pointValue;
  final bool isCompleted;
  final ActivityType type;

  Activity({
    required this.id,
    required this.title,
    required this.pointValue,
    this.isCompleted = false,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'pointValue': pointValue,
      'isCompleted': isCompleted,
      'type': type.name,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      pointValue: map['pointValue']?.toInt() ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      type: ActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActivityType.breathing,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Activity.fromJson(String source) =>
      Activity.fromMap(json.decode(source));

  Activity copyWith({
    String? id,
    String? title,
    int? pointValue,
    bool? isCompleted,
    ActivityType? type,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      pointValue: pointValue ?? this.pointValue,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
    );
  }
}

class Roadmap {
  final String id;
  final String userId;
  final String title;
  final List<Activity> activities;
  final bool isCompleted;

  Roadmap({
    required this.id,
    required this.userId,
    required this.title,
    required this.activities,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'activities': activities.map((x) => x.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory Roadmap.fromMap(Map<String, dynamic> map) {
    return Roadmap(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      activities: List<Activity>.from(
        (map['activities'] as List<dynamic>?)?.map(
              (x) => Activity.fromMap(x as Map<String, dynamic>),
            ) ??
            [],
      ),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Roadmap.fromJson(String source) =>
      Roadmap.fromMap(json.decode(source));

  Roadmap copyWith({
    String? id,
    String? userId,
    String? title,
    List<Activity>? activities,
    bool? isCompleted,
  }) {
    return Roadmap(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      activities: activities ?? this.activities,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
