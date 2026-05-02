# Safea 🛡️ — AI Safety Companion

**Safea** (Safety & Ease App) adalah ruang aman digital yang dirancang khusus untuk mendampingi penyintas kekerasan seksual pada **10 menit pertama** yang krusial setelah kejadian. 

Aplikasi ini berfungsi sebagai jembatan stabilisasi emosi dan keamanan fisik, memberikan Pertolongan Psikologis Pertama (PFA) melalui pendekatan **Trauma-Informed Care (TIC)** yang mengutamakan validasi tanpa penghakiman.

---

## 🌟 Visi & Latar Belakang
Pada momen pasca-trauma, penyintas sering kali mengalami syok hebat, disosiasi, atau kepanikan (fight-flight-freeze). Safea hadir untuk mengisi kekosongan bantuan instan sebelum bantuan profesional atau medis dapat dijangkau.

**Prinsip Utama:**
- **Non-Diagnostic:** Sistem tidak melakukan diagnosis medis/psikologis, melainkan stabilisasi emosi.
- **TIC-Driven UI:** Antarmuka didesain untuk meminimalisir *trigger* sensorik dan memberikan rasa kendali penuh kepada pengguna.
- **Survivor-Centric:** Memastikan keamanan fisik dan privasi data di atas segalanya.

---

## 🏗️ Arsitektur Sistem & Spesifikasi Teknologi

Safea mengadopsi arsitektur *hybrid* untuk menyeimbangkan kecepatan respons (real-time) dengan privasi data yang ketat.

### 📱 Frontend (Mobile)
- **Framework:** Flutter (Android & iOS).
- **Architecture:** **Clean Architecture** (Separation of Concerns: Data, Domain, and Presentation layers).
- **State Management:** Provider/Bloc (disesuaikan dengan skalabilitas).
- **Security:** Hardware-backed encryption via `flutter_secure_storage`.

### ⚙️ Backend (API & Real-time)
- **Framework:** Python dengan **FastAPI**.
- **Communication:** **Full-Duplex WebSockets** untuk pemrosesan aliran data audio secara waktu nyata (real-time streaming).
- **Server:** Uvicorn/Gunicorn.

### 🧠 Machine Learning & AI
- **On-Device Inference:** Model **TensorFlow Lite (.tflite)** untuk deteksi cepat pada perangkat lokal.
- **Cloud/Server Inference:** Arsitektur **Transformer Audio** (Wav2Vec 2.0) yang telah disesuaikan (*fine-tuned*) untuk memahami nuansa bahasa dan intonasi Indonesia.
- **SER (Speech Emotion Recognition):** Ekstraksi fitur akustik (MFCC) untuk mendeteksi spektrum kepanikan tanpa menyimpan rekaman suara mentah demi privasi.

---

## 🚀 Fitur Utama

### 1. Trauma-Informed Conversational AI
Asisten suara dan teks yang dilengkapi dengan *strict guardrails*. Instruksi sistem dirancang khusus untuk mencegah *victim-blaming* dan fokus pada teknik regulasi pernapasan serta stabilisasi kognitif.

### 2. Speech Emotion Recognition (SER)
Sistem menganalisis pola intonasi, ritme, dan frekuensi suara pengguna untuk mengidentifikasi tingkat kecemasan atau disosiasi. Jika terdeteksi sinyal kepanikan tinggi, AI akan menyesuaikan nada bicara dan kecepatan respons untuk menenangkan pengguna.

### 3. Crisis Routing (Eskalasi Cepat)
Logika deterministik yang memantau sinyal risiko tinggi (misal: risiko menyakiti diri atau ancaman fisik berkelanjutan). Secara otomatis menampilkan tombol akses cepat ke layanan darurat rujukan seperti:
- **SAPA 129** (KemenPPPA)
- **Satgas PPKS** di lingkungan institusi
- Kontak darurat personal pilihan pengguna.

### 4. Evidence Vault (Brankas Bukti)
Modul penyimpanan aman untuk kronologi kejadian dan bukti digital:
- **Encryption:** Militer-grade **AES-256** (Mode: CBC/GCM dengan PKCS7 Padding).
- **Authentication:** Dual-layer PIN lokal dan biometrik.
- **Hardware Protection:** Pengelolaan kunci enkripsi pada Secure Enclave (iOS) atau KeyStore (Android).
- **Quick Exit:** Fitur penghapusan instan atau penyamaran aplikasi jika situasi menjadi tidak aman bagi penyintas.

---

## 🛠️ Metodologi Pengembangan: Vibe Coding
Proyek ini dikembangkan menggunakan paradigma **Vibe Coding** di platform **Google Antigravity**, yang mengintegrasikan kecerdasan agen untuk mempercepat siklus *research-to-production*.

**Infrastruktur Panduan AI:**
- **Agent Manager:** Mengelola eksekusi tugas asinkron dengan validasi draf melalui mekanisme **Artifacts**.
- **Ground Rules:** Kepatuhan ketat terhadap pedoman arsitektur dan etika yang didefinisikan dalam `.agent/rules.md`.
- **Progressive Disclosure Skills:** Pendelegasian keahlian operasional spesifik lewat **SKILL.md** menggunakan konsep **Progressive Disclosure** untuk efisiensi konteks agen.

---

## 📥 Instalasi & Konfigurasi

### Prasyarat
- Flutter SDK (Versi terbaru)
- Python 3.9+
- TensorFlow Lite runtime

### 1. Setup Backend (FastAPI)
```bash
# Masuk ke direktori backend
cd safea_backend

# Inisialisasi lingkungan virtual
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Instalasi dependensi
pip install -r requirements.txt

# Jalankan server
uvicorn main:app --reload
```

### 2. Setup Frontend (Flutter)
```bash
# Masuk ke direktori aplikasi
cd safea_app

# Ambil paket dependensi
flutter pub get

# Jalankan aplikasi
flutter run
```

### 3. Konfigurasi Lingkungan
Buat berkas `.env` pada folder root backend dan frontend untuk menyimpan API Key secara aman:
```env
# Backend .env
DATABASE_URL=your_db_url
SECRET_KEY=your_encryption_secret

# Frontend (via flutter_dotenv atau build-args)
API_BASE_URL=http://localhost:8000
```

---

## ⚖️ Pernyataan Keamanan & Privasi
Safea tidak menyimpan data sensitif di peladen dalam bentuk teks mentah (*plain text*). Semua data di *Evidence Vault* dienkripsi secara lokal di perangkat pengguna. Kami berkomitmen pada transparansi algoritma AI untuk menghindari bias dalam penanganan penyintas.

---
*Safea: Because those first 10 minutes matter most.*
