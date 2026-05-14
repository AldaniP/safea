import 'dart:convert';

enum SessionStatus { scheduled, active, completed, cancelled }

class ConsultationSession {
  final String id;
  final String userId;
  final String therapistId;
  final DateTime scheduledTime;
  final String rtcChannelName;
  final String securityToken;
  final SessionStatus status;

  ConsultationSession({
    required this.id,
    required this.userId,
    required this.therapistId,
    required this.scheduledTime,
    required this.rtcChannelName,
    required this.securityToken,
    this.status = SessionStatus.scheduled,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'therapistId': therapistId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'rtcChannelName': rtcChannelName,
      'securityToken': securityToken,
      'status': status.name,
    };
  }

  factory ConsultationSession.fromMap(Map<String, dynamic> map) {
    return ConsultationSession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      therapistId: map['therapistId'] ?? '',
      scheduledTime: DateTime.parse(map['scheduledTime']),
      rtcChannelName: map['rtcChannelName'] ?? '',
      securityToken: map['securityToken'] ?? '',
      status: SessionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SessionStatus.scheduled,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ConsultationSession.fromJson(String source) =>
      ConsultationSession.fromMap(json.decode(source));

  ConsultationSession copyWith({
    String? id,
    String? userId,
    String? therapistId,
    DateTime? scheduledTime,
    String? rtcChannelName,
    String? securityToken,
    SessionStatus? status,
  }) {
    return ConsultationSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      therapistId: therapistId ?? this.therapistId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      rtcChannelName: rtcChannelName ?? this.rtcChannelName,
      securityToken: securityToken ?? this.securityToken,
      status: status ?? this.status,
    );
  }
}
