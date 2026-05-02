# Safea - Keamanan & Ketenangan

Safea adalah aplikasi Flutter premium yang dirancang untuk memberikan rasa aman dan stabilitas emosional melalui teknologi. Dengan antarmuka berbasis **Glassmorphism**, Safea menawarkan pengalaman pengguna yang tenang dan modern, fokus pada kesehatan mental dan privasi data.

## Fitur Utama

- **Tenang Dulu (Breathing Exercise):** Fitur latihan pernapasan interaktif menggunakan teknik _Box Breathing_ (4-4-4-4) untuk membantu meredakan kecemasan dan stres secara instan.
- **Secure Vault:** Layanan enkripsi data tingkat tinggi menggunakan standar **AES-256 (CBC Mode)** untuk memastikan data sensitif pengguna tetap privat dan aman di dalam perangkat.
- **Real-time Emotion Analysis:** Integrasi via WebSocket (SocketService) untuk streaming data audio ke server backend (FastAPI) guna analisis emosi secara langsung.
- **Desain Glassmorphism:** Estetika visual yang tactile dan premium dengan efek _frosted glass_, gradasi lembut, dan animasi halus menggunakan flutter_animate.

## Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Navigation:** GoRouter
- **Real-time Communication:** Socket.io Client
- **Security & Encryption:** Encrypt, Flutter Secure Storage
- **UI & Animations:** Flutter Animate, Google Fonts
- **Machine Learning Integration:** TFLite Flutter (Ready for edge inference)

## Arsitektur Proyek

Proyek ini mengikuti pola arsitektur yang bersih dengan pemisahan tanggung jawab yang jelas:

- **lib/screens/**: Berisi UI tingkat halaman (misal: HomeScreen).
- **lib/widgets/**: Komponen UI yang dapat digunakan kembali (misal: GlassCard, BreathingExerciseWidget).
- **lib/services/**: Logika bisnis dan infrastruktur (Singleton pattern):
  - SecureVaultService: Mengelola enkripsi AES-256 dan penyimpanan kunci aman.
  - SocketService: Mengelola komunikasi WebSocket real-time.
- **lib/theme/**: Konfigurasi tema global (Light/Dark mode) dan palet warna.

## Keamanan Data

Safea mengutamakan privasi pengguna dengan implementasi keamanan berikut:

1. **Penyimpanan Kunci Aman:** Kunci enkripsi disimpan di _Hardware-backed storage_ (Keychain/Keystore) menggunakan flutter_secure_storage.
2. **Enkripsi AES-256:** Data sensitif dienkripsi sebelum disimpan atau dikirim.
3. **Anti-Leak Logging:** Penanganan error yang ketat untuk mencegah kebocoran informasi teknis atau kriptografis dalam log sistem.

## Memulai

### Prasyarat

- Flutter SDK (Versi stabil terbaru)
- Dart SDK

### Instalasi

1. Clone repositori ini.
2. Jalankan perintah untuk mengambil dependensi:

   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi:

   ```bash
   flutter run
   ```
