import 'dart:convert';

class Assessment {
  final String id;
  final String userId;
  final DateTime timestamp;
  final Map<int, int> responses;
  final int depressionScore;
  final int anxietyScore;
  final int stressScore;
  final String? audioAnalysisResult;

  Assessment({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.responses,
    required this.depressionScore,
    required this.anxietyScore,
    required this.stressScore,
    this.audioAnalysisResult,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'responses': responses.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'depressionScore': depressionScore,
      'anxietyScore': anxietyScore,
      'stressScore': stressScore,
      'audioAnalysisResult': audioAnalysisResult,
    };
  }

  factory Assessment.fromMap(Map<String, dynamic> map) {
    return Assessment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      responses: (map['responses'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(int.parse(key), value as int),
      ),
      depressionScore: map['depressionScore']?.toInt() ?? 0,
      anxietyScore: map['anxietyScore']?.toInt() ?? 0,
      stressScore: map['stressScore']?.toInt() ?? 0,
      audioAnalysisResult: map['audioAnalysisResult'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Assessment.fromJson(String source) =>
      Assessment.fromMap(json.decode(source));
}
