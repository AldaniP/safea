import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GeminiLiveService {
  WebSocketChannel? _channel;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isConnected = false;

  StreamSubscription? _audioSubscription;
  StreamSubscription? _wsSubscription;

  final List<Uint8List> _audioQueue = [];
  bool _isPlaying = false;
  final List<int> _audioBuffer = [];
  Timer? _bufferTimer;
  Completer<void>? _activeCompleter;
  bool _isInterrupted = false;

  Future<void> connect() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key tidak ditemukan di .env');
    }

    // Menggunakan endpoint v1alpha untuk Multimodal Live API
    final uri = Uri.parse(
      'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent?key=$apiKey',
    );

    try {
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      // Kirim pesan setup
      final setupMessage = {
        "setup": {
          "model": "models/gemini-3.1-flash-live-preview",
          "generationConfig": {
            "responseModalities": ["AUDIO"],
            "speechConfig": {
              "voiceConfig": {
                "prebuiltVoiceConfig": {
                  "voiceName": "Puck",
                }, // Nama suara bawaan
              },
            },
          },
          "systemInstruction": {
            "parts": [
              {
                "text":
                    "Kamu adalah Safea, asisten virtual kesehatan mental. Dengarkan pengguna dengan penuh empati. Pahami emosi mereka dari nada suara mereka (SER). Balas dengan suara yang menenangkan dan penuh empati.",
              },
            ],
          },
        },
      };

      _channel!.sink.add(jsonEncode(setupMessage));

      // Kirim pesan awal untuk memicu respon (diagnostik)
      Future.delayed(const Duration(seconds: 1), () {
        if (_isConnected && _channel != null) {
          final initMessage = {
            "clientContent": {
              "turns": [
                {
                  "role": "user",
                  "parts": [
                    {"text": "Halo Safea, saya sudah terhubung."},
                  ],
                },
              ],
              "turnComplete": true,
            },
          };
          _channel!.sink.add(jsonEncode(initMessage));
          debugPrint('Sent initial message to trigger response');
        }
      });

      // Dengarkan respon dari server
      _wsSubscription = _channel!.stream.listen(
        (message) {
          _handleWsMessage(message);
        },
        onError: (error) {
          debugPrint('WebSocket Error: \$error');
          disconnect();
        },
        onDone: () {
          final closeCode = _channel?.closeCode;
          final closeReason = _channel?.closeReason;
          debugPrint('WebSocket Done. Code: $closeCode, Reason: $closeReason');
          disconnect();
        },
      );

      // Mulai merekam suara
      await _startRecording();
    } catch (e) {
      debugPrint('Failed to connect: \$e');
      disconnect();
      rethrow;
    }
  }

  void _handleWsMessage(dynamic message) async {
    try {
      String messageStr;
      if (message is String) {
        messageStr = message;
      } else if (message is List<int>) {
        messageStr = utf8.decode(message);
      } else {
        messageStr = message.toString();
      }

      debugPrint(
        'WS Message received: ${messageStr.substring(0, messageStr.length > 100 ? 100 : messageStr.length)}...',
      );
      final data = jsonDecode(messageStr);
      if (data['serverContent'] != null) {
        if (data['serverContent']['interrupted'] == true) {
          debugPrint('AI diinterupsi oleh pengguna! Menghentikan audio.');
          _isInterrupted = true;
          _audioQueue.clear();
          _audioBuffer.clear();
          await _player.stop();
          _isPlaying = false;
          if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
            _activeCompleter!.complete();
          }
          return;
        }

        final modelTurn = data['serverContent']['modelTurn'];
        if (modelTurn != null && modelTurn['parts'] != null) {
          _isInterrupted =
              false; // Reset status interupsi saat menerima turn baru
          for (var part in modelTurn['parts']) {
            if (part['inlineData'] != null &&
                part['inlineData']['mimeType'].startsWith('audio/')) {
              final base64Audio = part['inlineData']['data'];
              final mimeType = part['inlineData']['mimeType'];
              debugPrint(
                'Audio data received! MimeType: $mimeType, Length: ${base64Audio.length}',
              );
              final bytes = base64Decode(base64Audio);
              _audioBuffer.addAll(bytes);

              _bufferTimer?.cancel();

              // Jika sudah terkumpul sekitar 1.5 detik audio (24kHz * 2 bytes * 1.5 = 72KB)
              if (_audioBuffer.length >= 72000) {
                _flushBuffer();
              } else {
                // Tunggu jika tidak ada data baru selama 200ms, lalu putar yang ada
                _bufferTimer = Timer(const Duration(milliseconds: 200), () {
                  _flushBuffer();
                });
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling message: $e');
    }
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      if (await _recorder.isRecording()) {
        return;
      }

      // Mulai merekam sebagai stream PCM 16-bit dengan peredam gema
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          echoCancel: true,
          noiseSuppress: true,
          autoGain: true,
        ),
      );

      _audioSubscription = stream.listen((data) {
        if (_isConnected && _channel != null) {
          final base64Data = base64Encode(data);
          final inputMessage = {
            "realtimeInput": {
              "audio": {"mimeType": "audio/pcm;rate=16000", "data": base64Data},
            },
          };
          _channel!.sink.add(jsonEncode(inputMessage));
        }
      });
    } else {
      throw Exception('Izin mikrofon ditolak');
    }
  }

  void _flushBuffer() {
    if (_audioBuffer.isEmpty) return;

    final chunkBytes = Uint8List.fromList(_audioBuffer);
    _audioBuffer.clear();
    _audioQueue.add(chunkBytes);

    if (!_isPlaying) {
      _processAudioQueue();
    }
  }

  Future<void> _processAudioQueue() async {
    if (_isInterrupted || _audioQueue.isEmpty) {
      _isPlaying = false;
      return;
    }
    _isPlaying = true;
    final bytes = _audioQueue.removeAt(0);
    await _playAudio(bytes);
    if (!_isInterrupted) {
      _processAudioQueue(); // Process next in queue
    } else {
      _isPlaying = false;
    }
  }

  Future<void> _playAudio(Uint8List bytes) async {
    final completer = Completer<void>();
    _activeCompleter = completer;
    StreamSubscription? subscription;

    try {
      final wavBytes = _addWavHeader(bytes);

      debugPrint(
        'Playing audio with WAV header. Total length: ${wavBytes.length}',
      );

      // Menggunakan Data URI untuk kompatibilitas Web yang lebih baik
      final uri = Uri.dataFromBytes(wavBytes, mimeType: 'audio/wav').toString();

      subscription = _player.onPlayerComplete.listen((_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        subscription?.cancel();
      });

      await _player.play(UrlSource(uri));

      // Tunggu sampai audio selesai diputar
      await completer.future;
    } catch (e) {
      debugPrint('Error playing audio: $e');
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }
    } finally {
      _activeCompleter = null;
    }
  }

  Uint8List _addWavHeader(Uint8List pcmBytes) {
    final header = Uint8List(44);
    final bdata = ByteData.view(header.buffer);

    // RIFF header
    bdata.setUint32(0, 0x52494646, Endian.big); // "RIFF"
    bdata.setUint32(4, 36 + pcmBytes.length, Endian.little);
    bdata.setUint32(8, 0x57415645, Endian.big); // "WAVE"

    // fmt chunk
    bdata.setUint32(12, 0x666d7420, Endian.big); // "fmt "
    bdata.setUint32(16, 16, Endian.little); // size of fmt chunk
    bdata.setUint16(20, 1, Endian.little); // PCM format (1 = Linear PCM)
    bdata.setUint16(22, 1, Endian.little); // mono (1 channel)
    bdata.setUint32(24, 24000, Endian.little); // sample rate (24kHz)
    bdata.setUint32(28, 24000 * 1 * 16 ~/ 8, Endian.little); // byte rate
    bdata.setUint16(32, 1 * 16 ~/ 8, Endian.little); // block align
    bdata.setUint16(34, 16, Endian.little); // bits per sample

    // data chunk
    bdata.setUint32(36, 0x64617461, Endian.big); // "data"
    bdata.setUint32(40, pcmBytes.length, Endian.little);

    final wavBytes = Uint8List(44 + pcmBytes.length);
    wavBytes.setRange(0, 44, header);
    wavBytes.setRange(44, wavBytes.length, pcmBytes);
    return wavBytes;
  }

  Future<void> disconnect() async {
    _isConnected = false;
    await _audioSubscription?.cancel();
    await _wsSubscription?.cancel();
    await _recorder.stop();
    await _channel?.sink.close();
    await _player.stop();
    _audioQueue.clear();
    _isPlaying = false;
    _audioBuffer.clear();
    _bufferTimer?.cancel();
  }
}
