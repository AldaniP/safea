import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Kelas Singleton sentral untuk mengelola operasi enkripsi data sensitif.
/// Menerapkan standar AES-256 mode CBC dengan padding PKCS7.
class SecureVaultService {
  // --- Singleton Pattern ---
  SecureVaultService._privateConstructor();
  static final SecureVaultService _instance =
      SecureVaultService._privateConstructor();
  static SecureVaultService get instance => _instance;

  // Fasilitas penyimpanan aman dari device (Keychain di iOS / Keystore di Android)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Kunci identifikasi penyimpanan untuk Auth Key
  static const String _encryptionKeyStorageKey = 'safea_master_key_v1';

  // Kunci utama (32 bytes = 256 bits) yang disimpan dalam memori secara volatil
  Key? _encryptionKey;

  /// Inisialisasi vault.
  /// Berfungsi untuk memuat kunci 256-bit dari secure storage,
  /// atau menghasilkan kunci baru yang aman jika belum ada.
  Future<void> initialize() async {
    try {
      final storedKeyBase64 = await _secureStorage.read(
        key: _encryptionKeyStorageKey,
      );

      if (storedKeyBase64 != null) {
        // Menggunakan kunci yang sudah ada di Keystore/Keychain
        _encryptionKey = Key.fromBase64(storedKeyBase64);
      } else {
        // Menghasilkan kunci kriptografi acak baru sepanjang 32 bytes (AES-256)
        final newKey = Key.fromSecureRandom(32);
        _encryptionKey = newKey;

        // Menyimpan kunci ke fasilitas perangkat keras (secure storage)
        await _secureStorage.write(
          key: _encryptionKeyStorageKey,
          value: newKey.base64,
        );
      }
    } catch (e) {
      // Menangkap error untuk mencegah kebocoran log informasi sistem atau kunci
      throw Exception(
        'Gagal menginisialisasi Secure Vault: Operasi penyimpanan aman ditolak.',
      );
    }
  }

  /// Mengenkripsi teks biasa menggunakan AES-256 CBC berlapis Padding PKCS7.
  /// Menghasilkan format aman: Base64( IV (16 bytes) + CipherText )
  String encryptData(String plainText) {
    if (_encryptionKey == null) {
      throw Exception('Vault belum diinisialisasi. Sistem enkripsi terkunci.');
    }

    try {
      // 1. Hasilkan Vektor Inisialisasi (IV) acak sebesar 16 bytes untuk mode AES
      final iv = IV.fromSecureRandom(16);

      // 2. Konfigurasi Encrypter dengan algoritma AES-256 mode CBC (PKCS7 adalah standar bawaan)
      final encrypter = Encrypter(AES(_encryptionKey!, mode: AESMode.cbc));

      // 3. Proses enkripsi
      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // 4. Gabungkan (concatenate) byte IV murni diikuti dengan byte CipherText
      final combinedBytes = Uint8List.fromList([
        ...iv.bytes,
        ...encrypted.bytes,
      ]);

      // 5. Kembalikan gabungan tersebut sebagai satu enkoding string format base64
      return base64Encode(combinedBytes);
    } catch (e) {
      // Validasi anti-bocor: hindari menampilkan stack trace kriptografi
      throw Exception('Enkripsi data dibatalkan: Kesalahan integritas proses.');
    }
  }

  /// Mendekripsi string format Base64 yang berisi IV + CipherText kembali menjadi teks biasa.
  String decryptData(String encryptedBase64) {
    if (_encryptionKey == null) {
      throw Exception('Vault belum diinisialisasi. Sistem dekripsi terkunci.');
    }

    try {
      // 1. Decode string base64 untuk mengembalikan susunan byte gabungan
      final combinedBytes = base64Decode(encryptedBase64);

      // Validasi panjang minimum (karena IV memakan 16 bytes)
      if (combinedBytes.length < 16) {
        throw Exception(
          'Integritas data terkompromi: Panjang paket tidak valid.',
        );
      }

      // 2. Ekstraksi 16 bytes pertama sebagai Vektor Inisialisasi (IV)
      final ivBytes = combinedBytes.sublist(0, 16);
      final cipherBytes = combinedBytes.sublist(16);

      final iv = IV(Uint8List.fromList(ivBytes));
      final encrypted = Encrypted(Uint8List.fromList(cipherBytes));

      // 3. Konfigurasi ulang Encrypter untuk mode CBC menggunakan kunci master
      final encrypter = Encrypter(AES(_encryptionKey!, mode: AESMode.cbc));

      // 4. Proses pembalikan menjadi teks asli
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      // Validasi anti-bocor: error umum untuk salah kunci, data rusak, atau manipulasi
      throw Exception('Dekripsi data ditolak: Autentikasi paket gagal.');
    }
  }

  /// Secara eksplisit menghapus kunci dari memori aplikasi (digunakan saat logout/destroy)
  void lockVault() {
    _encryptionKey = null;
  }
}
