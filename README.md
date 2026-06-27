# SunVolt ☀️⚡
### Energi Masa Depan untuk Perjalanan Bersih

SunVolt adalah aplikasi mobile berbasis Flutter yang terintegrasi dengan perangkat keras IoT (Internet of Things). Dirancang untuk ekosistem kendaraan listrik masa depan dengan mengusung bahasa desain **"Solar Kinetic"**, aplikasi ini memberikan pengalaman pengguna yang premium, transparan, dan efisien dalam mengelola pengisian daya kendaraan listrik.

---

## 🚀 Fitur Utama

- **📍 Smart Location & Mapping**: 
  - Lacak lokasi pengguna secara real-time.
  - Temukan stasiun SunVolt terdekat dengan marker interaktif.
  - Perhitungan jarak tempuh motor yang akurat menggunakan API OSRM (Open Source Routing Machine).
- **📊 IoT Real-time Charging Monitor**: 
  - Terintegrasi dengan mikrokontroler **ESP32** dan **Sensor Arus ACS712**.
  - Pemantauan daya pengisian, waktu berjalan, dan biaya secara *real-time* yang disinkronisasi lewat Firebase Cloud Firestore.
  - Fitur *Auto-Stop* ketika baterai penuh atau biaya berjalan telah mencapai batas saldo.
- **💳 Integrated Digital Wallet**:
  - Top-up saldo instan melalui simulasi Sandbox Midtrans.
  - Manajemen riwayat aktivitas pengisian daya dan top-up (termasuk fitur hapus riwayat secara permanen).
- **🛡️ Keamanan & Konfirmasi**: Alur kerja yang ketat dengan dialog konfirmasi (`SunVoltConfirmationDialog`) untuk memulai/menghentikan pengisian daya dan transaksi guna mencegah kesalahan tindakan pengguna.
- **✨ Desain Premium "Solar Kinetic" (Pembaruan UI/UX)**:
  - **Efek Border Bergradien & Bayangan Tebal**: Semua tombol utama, tombol sekunder, dan kartu utama (seperti riwayat, status tarif, daya real-time, pilihan top-up, dan profil) kini menggunakan bingkai bergradien warna emas/hijau dan bayangan melayang dinamis untuk efek visual 3D yang hidup dan menonjol.
  - **Welcome & Splash Screen Premium**: Splash Screen dengan logo cincin konsentris berputar di bawah pendaran kuning-hijau, serta Welcome Screen berhiaskan lencana *frosted glass* (efek blur nyata) dan tombol masuk Google bersinar.
  - **Halaman Pembayaran QRIS Premium**: Area pemindai QRIS terbingkai rapi dengan kartu rincian tagihan berwarna gelap (*dark slate metallic*) bersinar nominal kuning emas.
- **🎬 Animasi Transisi Halus & Interaktif**:
  - **Transisi Geser Halaman**: Perpindahan antar tab navigasi bawah secara pintar mendeteksi arah geser (dari kiri ke kanan, atau sebaliknya) menggunakan penampil halaman dinamis `AnimatedIndexedStack` dengan kurva perlambatan `Curves.easeInOutCubic`.
  - **Bouncy Navigation Icon**: Tombol navigasi bawah memiliki efek membal (*bouncy scale* dengan `Curves.easeOutBack`) dan pendaran bayangan kuning neon saat aktif.
- **🔋 Ketahanan Sesi Latar Belakang (*Session Resiliency*)**:
  - **Auto-Resume**: Pemulihan otomatis sesi pengisian daya jika aplikasi tidak sengaja ditutup paksa atau perangkat mati. Splash screen akan langsung mendeteksi sesi aktif di Firestore sekunder dan mengarahkan kembali pengguna ke halaman status.
  - **Kalkulasi Akurat**: Penghitungan waktu durasi pengisian berbasis selisih waktu mutlak (`DateTime.now()`), memastikan kalkulasi tetap akurat 100% meskipun aplikasi tertidur di latar belakang.

---

## 🛠️ Tech Stack & Hardware

### Software & Cloud
- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: Stateful Widgets & Centralized Services
- **Database & Auth**: [Firebase Ecosystem](https://firebase.google.com) (Firestore & Authentication)
- **Map & Location**: `flutter_map` (OpenStreetMap), `geolocator`, `http` (API OSRM)
- **UI & Animation**: `google_fonts`, Custom Animations, BackdropFilter (Glassmorphism)

### Hardware & IoT
- **Microcontroller**: ESP32 Dev Module (Komunikasi Wi-Fi ke Firebase Firestore)
- **Sensor Kelistrikan**: Modul Sensor Arus ACS712 (Pembacaan arus presisi tinggi)

---

## 📦 Struktur Proyek

```bash
SunVolt/
├── android/        # Konfigurasi platform Android
├── esp32/          # Kode program C++ (.ino) untuk mikrokontroler ESP32
├── lib/
│   ├── core/       # Tema, warna, navigasi, dan widget global (Button, AppBar, BottomNav)
│   ├── models/     # Model representasi data
│   ├── services/   # Logika interaksi dengan Firebase (Auth & Firestore)
│   └── screens/    # Antarmuka UI per modul (Home, Peta, Wallet, Riwayat, Payment)
└── pubspec.yaml    # Dependensi dan pustaka Flutter
```

---

## 🔒 Perlindungan Kredensial & Keamanan Repository

Demi menjaga keamanan sistem dan rahasia data proyek, konfigurasi repository Git telah diperbarui menggunakan aturan `.gitignore` yang ketat untuk mengabaikan berkas kredensial sensitif:
- Kunci konfigurasi Firebase (`android/app/google-services.json` dan `ios/Runner/GoogleService-Info.plist`).
- FlutterFire options (`lib/firebase_options.dart`).
- Environment variable variables (`.env`, `*.env`).
- Android Keystore, key properties (`key.properties`), dan local properties build properties (`local.properties`).

---

## 🏁 Cara Menjalankan

1. **Prasyarat**:
   - Flutter SDK terinstal (versi terbaru disarankan).
   - Arduino IDE dengan *board package* ESP32 dan *library* Firebase ESP Client terinstal.

2. **Instalasi Software (Aplikasi Flutter)**:
   ```bash
   git clone https://github.com/SAF134/SunVolt.git
   cd SunVolt
   flutter pub get
   flutter run
   ```

3. **Instalasi Hardware (ESP32)**:
   - Hubungkan ESP32 ke laptop.
   - Buka file `esp32/sunvolt_esp32.ino` di Arduino IDE.
   - Ubah konfigurasi `WIFI_SSID` dan `WIFI_PASSWORD` sesuai dengan koneksi internet Anda.
   - Pastikan variabel `USER_EMAIL` dan `USER_PASSWORD` diisi dengan email akun yang Anda gunakan di dalam aplikasi.
   - *Upload* kode ke dalam ESP32.

---

## 📄 Tim Pengembang

Proyek Sistem Terintegrasi (Tugas Akhir) - Universitas Telkom
- **Syauqi Akmal Fadhali** (Mobile Developer)
- **Fattah Ahmad Rasyad** (Hardware Developer)
- **Rizky Januar Hardi** (Embedded System Developer)

© 2026 SunVolt Indonesia Energy. Dikembangkan dengan ❤️ untuk bumi yang lebih hijau.
