# SunVolt ☀️⚡
### Energi Masa Depan untuk Perjalanan Bersih

SunVolt adalah aplikasi mobile berbasis Flutter yang dirancang untuk ekosistem kendaraan listrik masa depan. Mengusung bahasa desain **"Solar Kinetic"**, aplikasi ini memberikan pengalaman pengguna yang premium, transparan, dan efisien dalam mengelola kebutuhan pengisian daya kendaraan listrik.

---

## 🚀 Fitur Utama

- **📍 Smart Location & Mapping**: 
  - Lacak lokasi pengguna secara real-time.
  - Temukan stasiun SunVolt terdekat dengan marker interaktif.
  - Perhitungan jarak tempuh motor yang akurat menggunakan API OSRM (Open Source Routing Machine).
- **📊 Real-time Charging Monitor**: Pantau status pengisian daya (Tegangan, Arus, dan Total Energi) secara langsung dari perangkat Anda.
- **💳 Integrated Digital Wallet**:
  - Top-up saldo instan melalui simulasi QRIS.
  - Riwayat transaksi yang mendetail dan transparan.
- **🛡️ Keamanan & Konfirmasi**: Alur kerja yang aman untuk memulai dan menghentikan pengisian daya guna mencegah kesalahan penggunaan.
- **💎 Desain "Solar Kinetic"**: Antarmuka modern dengan konsep *tonal layering*, *glassmorphism*, dan tanpa garis (*no-line aesthetic*).

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: Stateful Widgets & Centralized Services
- **Database & Auth**: [Firebase](https://firebase.google.com) (Firestore & Authentication)
- **Map & Location**: 
  - `flutter_map` (OpenStreetMap)
  - `geolocator` untuk GPS
  - `http` untuk integrasi API OSRM
- **UI & Animation**: `google_fonts`, `lucide_icons`, dan Custom Animations.

---

## 📦 Struktur Proyek

```bash
lib/
├── core/           # Tema, warna, dan widget global (SunVoltAppBar, dll)
├── models/         # Model data (User, Station, Transaction)
├── services/       # Logika bisnis (Auth, Firestore, Location)
└── screens/        # UI per modul (Home, Wallet, History, Profile, dll)
```

---

## 🏁 Cara Menjalankan

1. **Prasyarat**:
   - Flutter SDK terinstal (versi terbaru disarankan).
   - Akun Firebase (opsional, jika ingin menghubungkan ke instance Anda sendiri).

2. **Instalasi**:
   ```bash
   git clone https://github.com/username/SunVolt.git
   cd SunVolt
   flutter pub get
   ```

3. **Menjalankan Aplikasi**:
   ```bash
   # Jalankan di emulator atau perangkat fisik
   flutter run
   ```

---

## 📄 Lisensi

© 2026 SunVolt Indonesia Energy. Dikembangkan dengan ❤️ untuk bumi yang lebih hijau.
