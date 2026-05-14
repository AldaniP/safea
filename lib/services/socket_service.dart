import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Kelas layanan (SocketService) manajer WebSocket untuk mengontrol
/// interaksi data streaming real-time secara dua arah dengan peladen Python FastAPI.
class SocketService {
  // --- Singleton Pattern ---
  SocketService._privateConstructor();
  static final SocketService _instance = SocketService._privateConstructor();
  static SocketService get instance => _instance;

  io.Socket? _socket;

  // StreamController untuk mendistribusikan aliran metadata tingkat stabilitas emosi ke UI
  final StreamController<Map<String, dynamic>> _emotionMetadataController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream utama untuk dipantau (listen) oleh antarmuka (UI) secara konstan
  Stream<Map<String, dynamic>> get emotionMetadataStream =>
      _emotionMetadataController.stream;

  // Reaktif notifier untuk memonitor status ketersediaan sinyal secara real-time
  final ValueNotifier<bool> connectionStatus = ValueNotifier<bool>(false);

  /// Membangun dan membuka jembatan WebSocket ke alamat peladen
  void connect(String serverUrl) {
    // Abaikan jika sudah ada koneksi TCP yang hidup
    if (_socket != null && _socket!.connected) return;

    // Guardrail: Konfigurasi tingkat tinggi untuk menjaga stabilitas kanal
    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports([
            'websocket',
          ]) // Memaksakan murni websocket agar responsif
          .disableAutoConnect() // Kendali inisiasi berada secara manual
          .enableReconnection() // Guardrail validasi koneksi ulang otomatis
          .setReconnectionAttempts(
            10,
          ) // Membatasi retry TCP jika lingkungan terputus total
          .setReconnectionDelay(
            2000,
          ) // Backoff jeda waktu per koneksi ulang (2 detik)
          .build(),
    );

    // -- Alur pendengaran kejadian koneksi --
    _socket!.onConnect((_) {
      debugPrint('📡 [SocketService] Sinyal Terkoneksi ke Peladen: $serverUrl');
      connectionStatus.value = true;
    });

    _socket!.onDisconnect((_) {
      debugPrint('⚠️ [SocketService] Sinyal Terputus dari Lingkungan TCP.');
      connectionStatus.value = false;
    });

    _socket!.onReconnect((attempt) {
      debugPrint(
        '🔄 [SocketService] Guardrail Bekerja: Koneksi ulang berhasil pada percobaan ke-$attempt',
      );
    });

    _socket!.onReconnectError((error) {
      debugPrint(
        '❌ [SocketService] Guardrail Gagal: Percobaan koneksi ulang ditolak - $error',
      );
    });

    // -- Alur penerimaan konstan nilai balikan metadata tingkat stabilitas emosi --
    _socket!.on('emotion_metadata_response', (data) {
      if (data != null && data is Map) {
        // Asumsi data datang dalam bentuk Dictionary / JSON Object dari Python FastAPI
        _emotionMetadataController.add(Map<String, dynamic>.from(data));
      }
    });

    // Mulai buka jembatan jaringan sekarang
    _socket!.connect();
  }

  /// Pengiriman partikel bit buffer (mikrofon) ke peladen secara konstan.
  /// Parameter [audioBuffer] idealnya direkam pada frekuensi dan potongan waktu tertentu (misal: 1 detik).
  void sendAudioStream(Uint8List audioBuffer) {
    if (_socket != null && _socket!.connected) {
      // Mengirimkan biner byte array langsung melalui jembatan websocket
      _socket!.emit('microphone_audio_stream', audioBuffer);
    } else {
      debugPrint(
        '⚠️ [SocketService] Paket buffer terbuang: Kanal websocket tidak tersedia.',
      );
    }
  }

  /// Menutup secara aman jembatan komunikasi jika sesi telah selesai
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      connectionStatus.value = false;
      debugPrint('🔌 [SocketService] Kanal ditutup secara manual.');
    }
  }

  /// Membersihkan sumber daya di memori jika kelas dihancurkan
  void dispose() {
    disconnect();
    _emotionMetadataController.close();
    connectionStatus.dispose();
  }
}
