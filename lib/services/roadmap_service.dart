import 'package:flutter/foundation.dart';
import '../models/roadmap_model.dart';
import 'point_notifier.dart';

class RoadmapService {
  // Singleton pattern
  RoadmapService._privateConstructor();
  static final RoadmapService _instance = RoadmapService._privateConstructor();
  static RoadmapService get instance => _instance;

  final ValueNotifier<Roadmap?> currentRoadmap = ValueNotifier<Roadmap?>(null);

  /// Generates a new roadmap based on assessment results.
  /// In a real app, this might come from the backend.
  void generateRoadmap(String userId, Map<String, int> scores) {
    final newRoadmap = Roadmap(
      id: 'roadmap_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: 'Jalur Ketenangan Personal Anda',
      activities: [
        Activity(
          id: 'a1',
          title: 'Tarik Napas Dalam (5 mnt)',
          pointValue: 10,
          type: ActivityType.breathing,
        ),
        Activity(
          id: 'a2',
          title: 'Meditasi Terpandu',
          pointValue: 20,
          type: ActivityType.meditation,
        ),
      ],
    );
    currentRoadmap.value = newRoadmap;
  }

  /// Marks an activity as completed and awards points
  Future<void> completeActivity(
    String activityId,
    PointNotifier pointNotifier,
  ) async {
    final roadmap = currentRoadmap.value;
    if (roadmap == null) return;

    final activities = List<Activity>.from(roadmap.activities);
    final activityIndex = activities.indexWhere((a) => a.id == activityId);

    if (activityIndex != -1 && !activities[activityIndex].isCompleted) {
      final activity = activities[activityIndex];
      activities[activityIndex] = activity.copyWith(isCompleted: true);

      // Check if all activities are completed
      final isAllCompleted = activities.every((a) => a.isCompleted);

      // Award points
      await pointNotifier.addPoints(activity.pointValue);

      // Update roadmap state
      currentRoadmap.value = roadmap.copyWith(
        activities: activities,
        isCompleted: isAllCompleted,
      );
    }
  }

  void dispose() {
    currentRoadmap.dispose();
  }
}
