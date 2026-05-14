import 'dart:async';
import 'package:flutter/foundation.dart';
import 'socket_service.dart';

class AnalysisService {
  final SocketService _socketService = SocketService.instance;

  // Stream for UI to listen to emotional metadata
  Stream<Map<String, dynamic>> get emotionalMetadataStream =>
      _socketService.emotionMetadataStream;

  ValueNotifier<bool> get isConnected => _socketService.connectionStatus;

  /// Starts the analysis session by connecting to the WebSocket
  void startAnalysis(String serverUrl, String userId, String assessmentId) {
    _socketService.connect(serverUrl);

    // In a real implementation, we would wait for connection then emit session start
    // For this prototype, we assume connection is managed by the UI lifecycle
  }

  /// Streams microphone audio to the backend
  void streamAudio(Uint8List audioBuffer) {
    _socketService.sendAudioStream(audioBuffer);
  }

  /// Stops the analysis session
  void stopAnalysis() {
    _socketService.disconnect();
  }

  /// Helper to convert raw metadata to character triggers
  String getCharacterTrigger(Map<String, dynamic> metadata) {
    // Logic from server-side 'character_trigger' or locally derived
    return metadata['character_trigger'] ?? 'idle';
  }

  /// Cleanup
  void dispose() {
    _socketService.dispose();
  }
}
