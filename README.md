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
  - Top-up saldo instan melalui simulasi Sanbox Midtrans.
  - Manajemen riwayat aktivitas pengisian daya dan top-up (termasuk fitur hapus riwayat secara permanen).
- **🛡️ Keamanan & Konfirmasi**: Alur kerja yang ketat untuk memulai dan menghentikan pengisian daya guna mencegah kesalahan penggunaan.
- **💎 Desain "Solar Kinetic"**: Antarmuka modern dengan konsep *tonal layering*, *glassmorphism*, dan desain minim garis (*no-line aesthetic*).

---

## 🛠️ Tech Stack & Hardware

### Software & Cloud
- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: Stateful Widgets & Centralized Services
- **Database & Auth**: [Firebase Ecosystem](https://firebase.google.com) (Firestore & Authentication)
- **Map & Location**: `flutter_map` (OpenStreetMap), `geolocator`, `http` (API OSRM)
- **UI & Animation**: `google_fonts`, Custom Animations

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
│   ├── core/       # Tema, warna, navigasi, dan widget global
│   ├── models/     # Model representasi data
│   ├── services/   # Logika interaksi dengan Firebase (Auth & Firestore)
│   └── screens/    # Antarmuka UI per modul (Home, Peta, Wallet, Riwayat)
└── pubspec.yaml    # Dependensi dan pustaka Flutter
```

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
