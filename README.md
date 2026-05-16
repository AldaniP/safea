# Safea - Trauma-Informed Mental Health App

Safea adalah aplikasi kesehatan mental berbasis *trauma-informed* yang dirancang untuk membantu pengguna mengelola stres, kecemasan, dan trauma dengan bantuan AI dan teknik psikologis yang tervalidasi.

## ✨ Fitur Utama

- **🧠 AI Companion**: Chatbot cerdas yang ditenagai oleh Google Gemini untuk mendengarkan dan memberikan dukungan emosional.
- **📊 Asesmen DASS-21**: Alat ukur psikologis tervalidasi untuk mengukur tingkat Depresi, Kecemasan (*Anxiety*), dan Stres.
- **🌬️ Tenang Dulu (Box Breathing)**: Latihan pernapasan terpandu untuk membantu regulasi sistem saraf.
- **🛡️ Safety Plan**: Fitur untuk membuat rencana keselamatan saat berada dalam kondisi krisis.
- **📈 Progress Tracking**: Visualisasi perkembangan kesehatan mental pengguna dari waktu ke waktu.
- **🤝 Konsultasi & Komunitas**: Akses ke bantuan profesional dan komunitas pendukung.

## 🛠️ Teknologi yang Digunakan

- **Framework**: Flutter
- **State Management**: Provider
- **Routing**: Go Router
- **AI Integration**: Google Generative AI (Gemini API)
- **UI/UX**: Glassmorphism Design, Lucide Icons, Google Fonts, Flutter Animate

## 🚀 Cara Memulai

### Prasyarat
- Flutter SDK
- API Key Google Gemini

### Instalasi

1. Ambil dependensi proyek:
   ```bash
   flutter pub get
   ```
2. Pastikan file `.env` ada di root proyek (atau buat baru) dan tambahkan API Key Gemini Anda:
   ```env
   GEMINI_API_KEY=your_api_key_here
   ```
3. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## 📂 Struktur Folder

- `lib/core`: Utilitas, konstanta, dan tema global.
- `lib/data`: Layanan data (termasuk integrasi Gemini).
- `lib/presentation`: Layanan UI (Screens dan Widgets).
- `lib/routing`: Konfigurasi navigasi aplikasi.

---
Dibuat dengan ❤️ untuk mendukung kesehatan mental yang lebih baik.
