# BAB II
# DESAIN KONSEP SOLUSI

## 2.1 Dasar Penentuan Spesifikasi
Penentuan spesifikasi dan batasan pada stasiun pengisian daya kendaraan listrik ringan (*Lightweight Electric Vehicle*/LEV) berbasis tenaga surya ini didasarkan pada landasan hukum (regulasi pemerintah), standar industri nasional/internasional, karakteristik teknis komponen kelistrikan, serta hasil survei kebutuhan pengguna di lapangan.

1.  **Regulasi Pemerintah Republik Indonesia:**
    *   **Peraturan Presiden (Perpres) Nomor 79 Tahun 2023** tentang Percepatan Program Kendaraan Bermotor Listrik Berbasis Baterai (KBLBB) untuk Transportasi Jalan [1]. Regulasi ini menjadi landasan hukum utama pengembangan ekosistem kendaraan listrik di Indonesia, termasuk infrastruktur pengisian dayanya.
    *   **Peraturan Menteri (Permen) ESDM Nomor 1 Tahun 2023** tentang Penyediaan Infrastruktur Pengisian Listrik untuk KBLBB [2]. Peraturan ini menetapkan klasifikasi teknologi pengisian, keselamatan operasi kelistrikan, serta kewajiban adanya sistem aplikasi daring yang terintegrasi untuk pemantauan transaksi energi.

2.  **Standar Industri dan Keamanan Kelistrikan:**
    *   **SNI IEC 61851-1:2019** (Sistem Pengisian Konduktif Kendaraan Listrik) [3], yang menetapkan standar keselamatan pengisian daya EV, termasuk proteksi arus berlebih (*overcurrent*), proteksi sengatan listrik, serta kestabilan suplai daya.
    *   **SNI IEC 60364** (Instalasi Listrik Voltase Rendah) sebagai acuan perancangan sistem distribusi daya AC dan DC yang aman di area luar ruangan (*outdoor*) [4].
    *   Karakteristik pengisian baterai Lithium-ion pada LEV: Sepeda listrik umumnya menggunakan baterai dengan tegangan nominal 48 V yang membutuhkan tegangan pengisian maksimum (*charging voltage*) sebesar **54.6 V DC** [5]. Sedangkan sepeda motor listrik di Indonesia mayoritas menggunakan *charger* eksternal bawaan pabrik yang memerlukan suplai daya **220 V AC, 50 Hz** dengan gelombang sinus murni (*Pure Sine Wave*) agar tidak merusak rangkaian penyearah di dalam *charger* [6].

3.  **Kebutuhan Pengguna dan Karakteristik Lingkungan Kampus:**
    *   Berdasarkan survei dan wawancara yang dilakukan terhadap **15-30 pengguna sepeda listrik dan motor listrik** di lingkungan Universitas Telkom, diperoleh data bahwa pengguna mengeluhkan ketiadaan tempat pengisian daya umum LEV yang aman dari risiko pencurian/korsleting saat hujan, serta menginginkan transparansi tarif berdasarkan jumlah energi yang dikonsumsi (Wh/kWh) [7].
    *   Lokasi geografis stasiun pengisian direncanakan di area kampus Universitas Telkom, Bandung, dengan rata-rata radiasi harian matahari berkisar 4-5 jam efektif untuk pemanenan energi surya off-grid [8].

---

## 2.2 Batasan dan Spesifikasi
Batasan kelayakan (*constraints*) didefinisikan untuk membatasi ruang lingkup perancangan sistem, sedangkan spesifikasi solusi dirancang berdasarkan kebutuhan perangkat lunak dan perangkat keras (*Software/System Requirements Specification* - SRS).

### 2.2.1 Batasan Masalah
Batasan lingkup masalah dalam perancangan stasiun pengisian daya LEV ini disajikan pada Tabel 2.1.

**Tabel 2.1 Batasan Lingkup Masalah**

| Kategori Batasan | Deskripsi Batasan |
| :--- | :--- |
| **Tujuan** | Sistem dirancang untuk menyediakan stasiun pengisian daya LEV (sepeda listrik dan motor listrik) secara mandiri (*off-grid*) dengan memanfaatkan Pembangkit Listrik Tenaga Surya (PLTS) sebagai sumber energi utama, dilengkapi dengan sistem monitoring telemetri kelistrikan dan kontrol relay berbasis IoT. |
| **Target Pengguna** | Sivitas akademika Universitas Telkom (mahasiswa, dosen, staf) yang memiliki kendaraan listrik ringan berupa sepeda listrik (DC) atau motor listrik (AC). |
| **Lingkungan** | Stasiun pengisian diletakkan di luar ruangan (*outdoor*) pada area kampus Universitas Telkom. Oleh karena itu, perangkat fisik stasiun harus terlindung dari paparan cuaca (panas matahari dan hujan ringan) dengan tingkat proteksi box panel minimal IP54. |
| **Biaya** | Anggaran pengadaan komponen perangkat keras dibatasi agar tetap ekonomis untuk skala implementasi kampus, serta tarif energi yang dikenakan kepada pengguna bersifat non-profit/terjangkau untuk kalangan mahasiswa. |

### 2.2.2 Deskripsi Spesifikasi Perangkat Keras (Hardware Requirements)
Berikut adalah deskripsi rinci spesifikasi perangkat keras stasiun pengisian daya SunVolt:

*   **SR.HW.1: Perangkat dapat mengisi daya dari tenaga surya.**
    Perangkat ini dirancang sebagai sistem mandiri (*off-grid*) yang memanfaatkan energi terbarukan. Sistem manajemen daya difokuskan untuk mengonversi energi fotovoltaik dari 4 unit panel surya 100 Wp menggunakan MPPT Solar Charge Controller (SCC) 48V 60A menjadi energi listrik yang stabil untuk disimpan ke dalam bank baterai utama SLA 48V 12Ah sebelum didistribusikan ke kendaraan [14].
*   **SR.HW.2: Perangkat dapat mengisi daya ke sepeda listrik dan motor listrik secara bersamaan.**
    Perangkat dilengkapi dengan arsitektur *dual-output* yang memungkinkan distribusi arus ke dua port berbeda dalam satu waktu. Hal ini bertujuan untuk meningkatkan efisiensi pelayanan stasiun. Port DC (54.6V 20A via DC-DC Boost Converter) melayani sepeda listrik, sedangkan Port AC (220V AC via Inverter Pure Sine Wave 1000W) melayani pengisian motor listrik.
*   **SR.HW.3: Perangkat dapat menghentikan pengisian daya secara otomatis ketika baterai telah terisi penuh atau batas yang sudah ditentukan.**
    Sistem proteksi pengisian daya (*cut-off protection*) diimplementasikan melalui mikrokontroler ESP32-U WROOM yang memantau parameter arus dan tegangan beban menggunakan sensor INA219. Fitur ini berfungsi vital untuk memutuskan aliran relay stasiun secara otomatis saat baterai penuh (arus turun di bawah 0,05 A) atau jika saldo dompet pengguna habis [15].
*   **SR.HW.4: Perangkat dapat beralih sumber listrik dari baterai ke jaringan listrik PLN maupun sebaliknya.**
    Sistem hibrida diterapkan menggunakan mekanisme *Automatic Transfer Switch* (ATS) untuk menjamin ketersediaan layanan (*availability*). Ketika daya dari panel surya atau baterai utama stasiun berada di bawah ambang batas minimum pengoperasian, sistem kelistrikan akan secara otomatis memindahkan catu daya ke jaringan cadangan PLN tanpa mengganggu proses pengisian yang sedang berlangsung [16].

### 2.2.3 Deskripsi Spesifikasi Fungsional Perangkat Lunak
Kebutuhan fungsional perangkat lunak direalisasikan dalam bentuk aplikasi mobile SunVolt (Flutter) dan serverless backend Vercel. Deskripsi spesifikasi fungsional disajikan dalam Tabel 2.3.

**Tabel 2.3 Deskripsi Spesifikasi Fungsional Perangkat Lunak**

| No | Kode | Nama Spesifikasi | Deskripsi Spesifikasi |
| :---: | :---: | :--- | :--- |
| 1 | **FR-SW-01** | Autentikasi Akun | Aplikasi mampu membuat akun pengguna dengan menggunakan akun google. |
| 2 | **FR-SW-02** | Top Up Saldo Dompet | Aplikasi mampu melakukan top up saldo dompet melalui payment gateway. |
| 3 | **FR-SW-03** | Monitoring Daya dan Tarif | Aplikasi mampu memantau daya yang masuk dan memantau tarif pengisian daya. |
| 4 | **FR-SW-04** | Data Riwayat Aktivitas | Aplikasi mampu menyimpan data riwayat aktivitas seperti top up saldo dompet dan data selesai pengisian. |

### 2.2.4 Deskripsi Spesifikasi Non-Fungsional Perangkat Lunak
Spesifikasi non-fungsional aplikasi mobile SunVolt mencakup aspek performa, keamanan, ketersediaan, dan kemudahan penggunaan. Deskripsi spesifikasi non-fungsional disajikan dalam Tabel 2.4.

**Tabel 2.4 Deskripsi Spesifikasi Non-Fungsional Perangkat Lunak**

| No | Kode | Nama Spesifikasi | Deskripsi Spesifikasi |
| :---: | :---: | :--- | :--- |
| 1 | **NFR-SW-01** | Availability (Ketersediaan Layanan) | Sistem database Firestore dan backend harus memiliki persentase waktu aktif (*uptime*) minimal 99% agar aplikasi mobile dapat diakses oleh pengguna setiap saat. |
| 2 | **NFR-SW-02** | Security (Keamanan Transaksi) | Sistem wajib mengamankan integritas saldo dompet digital pengguna menggunakan enkripsi koneksi HTTPS dan autentikasi token Firebase yang valid. |
| 3 | **NFR-SW-03** | Performance (Kecepatan Sinkronisasi) | Latensi sinkronisasi telemetri daya masuk antara ESP32, Firebase database, dan tampilan UI aplikasi mobile tidak boleh melebihi 1,5 detik. |
| 4 | **NFR-SW-04** | Usability (Kemudahan Antarmuka) | Aplikasi dirancang dengan antarmuka yang intuitif dengan waktu pemuatan halaman awal (*page load time*) di bawah 2 detik pada koneksi internet standar. |

---

## 2.3 Pengukuran/Verifikasi Spesifikasi
Pengukuran atau verifikasi spesifikasi dari perangkat diperlukan untuk memastikan kinerja dan kapabilitas di setiap sistem dari perangkat berjalan sesuai perancangan. Verifikasi dibagi menjadi spesifikasi perangkat keras dan spesifikasi perangkat lunak (fungsional & non-fungsional).

### 2.3.1 Verifikasi Spesifikasi Perangkat Keras
Verifikasi kelayakan perangkat kelistrikan stasiun disajikan pada Tabel 2.5.

**Tabel 2.5 Tabel Pengukuran dan Verifikasi Spesifikasi Perangkat Keras**

| No | Kode | Nama Spesifikasi | Alat Ukur/Verifikasi | Mekanisme Pengukuran |
| :---: | :---: | :--- | :--- | :--- |
| 1 | **SR.HW.1** | Pemanenan Energi Surya | Avometer/Multimeter Digital | Pengukuran dilakukan pada jalur kabel dari Panel Surya menuju input Solar Charge Controller (SCC). Pengujian dilakukan saat siang hari terik untuk memverifikasi tegangan $V_{oc}$ berada di atas tegangan baterai (> 48V) untuk pengisian aki. |
| 2 | **SR.HW.2** | Dual Output Simultan | Variable Dummy Load & Clamp Meter | Memberikan beban kelistrikan pada kedua port stasiun secara bersamaan. Mengukur arus masing-masing jalur untuk memverifikasi bahwa port AC dan DC mengalirkan daya stabil secara simultan tanpa memicu proteksi kelebihan beban. |
| 3 | **SR.HW.3** | Pengaman Auto Cut-off | Multimeter Digital & Indikator LED | Mengisi baterai beban hingga penuh. Memantau multimeter untuk memverifikasi arus pengisian terputus secara otomatis (menjadi 0 A) oleh aktuasi relay ketika arus sensor drop di bawah batas ambang 50mA. |
| 4 | **SR.HW.4** | Sistem Hibrida ATS | Multimeter & Lampu Indikator | Menyambungkan beban lampu ke stasiun. Memutuskan suplai baterai utama stasiun secara sengaja untuk mensimulasikan kondisi baterai habis (*Low Bat*), kemudian memverifikasi menggunakan multimeter bahwa suplai daya beralih ke PLN secara instan tanpa jeda pemutusan beban. |

### 2.3.2 Verifikasi Spesifikasi Fungsional Perangkat Lunak
Verifikasi kelayakan antarmuka pengguna dan integrasi IoT aplikasi SunVolt disajikan pada Tabel 2.6.

**Tabel 2.6 Tabel Pengukuran dan Verifikasi Spesifikasi Fungsional Perangkat Lunak**

| No | Kode SRS | Alat Ukur/Verifikasi | Mekanisme Pengukuran/Verifikasi |
| :---: | :---: | :--- | :--- |
| 1 | **FR-SW-01** | Firebase Console & Google Auth UI | 1. Buka aplikasi, ketuk tombol Google Login.<br>2. Pilih akun Google dan verifikasi proses autentikasi berhasil.<br>3. Periksa Firebase Console untuk memastikan UID pengguna terbuat secara otomatis. |
| 2 | **FR-SW-02** | Midtrans Sandbox & Firestore Console | 1. Lakukan transaksi top-up nominal saldo di aplikasi.<br>2. Ambil Snap Token dari Midtrans Sandbox untuk memunculkan QRIS.<br>3. Selesaikan simulasi bayar lunas pada simulator sandbox dan pastikan saldo di Firestore bertambah secara otomatis. |
| 3 | **FR-SW-03** | Aplikasi Mobile UI & Firestore Real-Time Database | 1. Lakukan sesi pengisian daya aktif.<br>2. Amati data daya Watt masuk yang ter-update secara berkala pada grafik aplikasi.<br>3. Amati perhitungan tarif berjalan terakumulasi di UI secara real-time berdasarkan konsumsi daya terpakai. |
| 4 | **FR-SW-04** | Firestore Log Collection & History Screen | 1. Jalankan aktivitas pengisian daya atau top-up saldo hingga selesai.<br>2. Periksa koleksi database di Firestore untuk memverifikasi dokumen log riwayat baru tersimpan.<br>3. Buka halaman riwayat di aplikasi mobile dan pastikan data log ter-render dengan benar. |

### 2.3.3 Verifikasi Spesifikasi Non-Fungsional Perangkat Lunak
Verifikasi parameter kualitas non-fungsional aplikasi SunVolt disajikan pada Tabel 2.7.

**Tabel 2.7 Tabel Pengukuran dan Verifikasi Spesifikasi Non-Fungsional Perangkat Lunak**

| No | Kode SRS | Alat Ukur/Verifikasi | Mekanisme Pengukuran/Verifikasi |
| :---: | :---: | :--- | :--- |
| 1 | **NFR-SW-01** | Uptime Robot / Cloud Console Logs | Memantau kegagalan akses API Vercel dan Firestore database selama pengujian operasional 7x24 jam untuk memastikan rasio ketersediaan sistem tetap di atas 99%. |
| 2 | **NFR-SW-02** | OWASP ZAP & Wireshark | Menguji pertukaran paket data top-up saldo dan sesi transaksi aktif untuk memastikan skema enkripsi menggunakan protokol HTTPS/TLS 1.3 dan memblokir akses tanpa token JWT. |
| 3 | **NFR-SW-03** | Firebase Profiler & Digital Stop Watch | Mengukur selisih waktu (delay) dari saat stasiun fisik mengirim data telemetri hingga nilai tersebut ter-render sepenuhnya pada UI aplikasi mobile. |
| 4 | **NFR-SW-04** | Flutter DevTools Profiler | Menjalankan aplikasi mobile pada perangkat uji Android dan mengukur waktu inisialisasi boot awal (*cold start*) aplikasi agar tetap berada di bawah 2 detik. |

---

## 2.4 Kesimpulan
Penyusunan konsep solusi (CD-2) ini merinci batasan kelayakan (*constraints*) dan spesifikasi solusi (SRS) yang menjadi acuan utama dalam pengembangan "Sistem Pengisian Daya Kendaraan Listrik Ringan Berbasis Tenaga Surya". Batasan sistem berfokus pada penyediaan stasiun pengisian mandiri (*off-grid*) luar ruangan untuk melayani dual output pengisian kendaraan listrik ringan (sepeda dan motor listrik) di lingkungan kampus Universitas Telkom.

Spesifikasi fungsional perangkat lunak dan perangkat keras dirancang secara ketat untuk menjawab permasalahan lapangan, di antaranya pemanenan surya off-grid, pengisian dual-output AC dan DC, sistem otomatis ATS, sistem monitoring kelistrikan terintegrasi Firebase Cloud Firestore, pembayaran dompet digital non-tunai via Midtrans, serta visualisasi stasiun berbasis peta digital. Seluruh spesifikasi tersebut dilengkapi dengan tabel metode pengukuran dan verifikasi yang sistematis, menjamin bahwa sistem yang dibangun dapat diuji kinerjanya secara empiris, aman dari segi kelistrikan, serta transparan bagi pengguna stasiun.

---

## Daftar Pustaka
```
[1]  Republik Indonesia, "Peraturan Presiden Nomor 79 Tahun 2023 tentang Perubahan atas Peraturan Presiden Nomor 55 Tahun 2019 tentang Percepatan Program Kendaraan Bermotor Listrik Berbasis Baterai (KBLBB) untuk Transportasi Jalan," Lembaran Negara RI, Jakarta, 2023.
[2]  Kementerian Energi dan Sumber Daya Mineral (ESDM) RI, "Peraturan Menteri ESDM Nomor 1 Tahun 2023 tentang Penyediaan Infrastruktur Pengisian Listrik untuk Kendaraan Bermotor Listrik Berbasis Baterai," JDIH Kementerian ESDM, Jakarta, 2023.
[3]  Badan Standardisasi Nasional (BSN), "SNI IEC 61851-1:2019 Sistem pengisian konduktif kendaraan listrik - Bagian 1: Persyaratan umum (IEC 61851-1:2017, IDT)," BSN, Jakarta, Indonesia, 2019.
[4]  Badan Standardisasi Nasional (BSN), "SNI IEC 60364 Persyaratan Umum Instalasi Listrik," BSN, Jakarta, Indonesia, 2020.
[5]  Adafruit Industries, "Adafruit INA219 High-Side DC Current Sensor Breakout Datasheet," Adafruit, 2022. [Online]. Available: https://learn.adafruit.com/adafruit-ina219-current-sensor-breakout.
[6]  Espressif Systems, "ESP32-WROOM-32U Series Datasheet v2.1," Espressif, 2023. [Online]. Available: https://www.espressif.com/documentation/esp32-wroom-32u_datasheet_en.pdf.
[7]  Midtrans Developer Portal, "Midtrans Snap Core API Integration Guide," Midtrans, 2024. [Online]. Available: https://docs.midtrans.com/.
[8]  Vercel Inc., "Vercel Serverless Functions Deployment Documentation," Vercel, 2025. [Online]. Available: https://vercel.com/docs/concepts/functions/serverless-functions.
```
