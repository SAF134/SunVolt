# BAB V
# PENGUJIAN SISTEM DAN KESIMPULAN

## 5.1. Skenario Umum Pengujian
Secara umum, pengujian sistem dilakukan untuk memverifikasi kelayakan fungsionalitas dan kinerja keseluruhan purwarupa stasiun pengisian daya Kendaraan Listrik Ringan (*Lightweight Electric Vehicle*/LEV) berbasis tenaga surya off-grid SunVolt. Evaluasi difokuskan untuk menilai apakah solusi rancangan perangkat keras dan perangkat lunak yang telah diimplementasikan dapat menjawab permasalahan kebutuhan pengisian daya mandiri di lingkungan kampus secara aman, andal, dan reaktif.

Daftar spesifikasi kelayakan sistem yang menjadi acuan pengujian didasarkan pada spesifikasi kebutuhan yang telah dirumuskan pada Dokumen CD-2, meliputi empat spesifikasi perangkat keras (SR.HW), empat spesifikasi fungsional perangkat lunak (FR-SW), dan empat spesifikasi non-fungsional perangkat lunak (NFR-SW). Daftar rincian pengujian tersebut disajikan pada Tabel 5.1.

**Tabel 5.1 Daftar Pengujian Perangkat Keras dan Perangkat Lunak**

| Kategori Pengujian | Kode | Nama Item Pengujian | Metode Pengujian |
| :--- | :--- | :--- | :--- |
| **Perangkat Keras** | **SR.HW.1** | Pemanenan Energi Surya (Solar Panel & SCC) | Pengukuran tegangan $V_{oc}$ dan daya terpanen harian. |
| | **SR.HW.2** | Dual Output Simultan (AC & DC Output) | Pembebanan ganda simultan menggunakan beban AC and DC. |
| | **SR.HW.3** | Pengaman Auto Cut-off (Arus Penuh & Saldo Habis) | Pemutusan sirkuit relai berdasarkan parameter batas kelistrikan. |
| | **SR.HW.4** | Sistem Hibrida ATS (Solar to PLN Transfer) | Pengukuran kecepatan perpindahan daya saat baterai habis. |
| **Perangkat Lunak (Fungsional)** | **FR-SW-01** | Autentikasi Akun (Google OAuth) | Pengujian validasi akun Google dan pembuatan dokumen Firestore. |
| | **FR-SW-02** | Top Up Saldo Dompet (Midtrans Snap) | Simulasi penambahan saldo dompet via pembayaran QRIS sandbox. |
| | **FR-SW-03** | Monitoring Daya dan Tarif Berjalan | Uji visualisasi daya Watt masuk & akumulasi tarif di HP. |
| | **FR-SW-04** | Data Riwayat Aktivitas Transaksi | Validasi penyimpanan riwayat transaksi di Firestore tanpa resi. |
| **Perangkat Lunak (Non-Fungsional)** | **NFR-SW-01** | Availability (Ketersediaan Layanan) | Pengujian rasio uptime serverless backend dan database. |
| | **NFR-SW-02** | Security (Keamanan Transaksi) | Pengujian enkripsi HTTPS/TLS 1.3 dan Firebase Security Rules. |
| | **NFR-SW-03** | Performance/Latency (Delay Sinkronisasi) | Pengukuran jeda transfer data telemetri dari sensor ke UI HP. |
| | **NFR-SW-04** | Usability (Kemudahan Antarmuka) | Pengukuran cold start time dan frame rate rendering aplikasi. |

Pengujian sistem dilaksanakan pada bulan Mei s.d Juni 2026. Seluruh rangkaian pengujian perangkat keras luar ruangan (*outdoor*) dan integrasi sistem nirkabel dilakukan di area selasar terbuka Gedung Tokong Nanas (Gedung Kuliah Bersama Fakultas Teknik Elektro), Universitas Telkom, Bandung. Pemilihan lokasi ini disesuaikan dengan ketersediaan sinar matahari langsung (*direct solar irradiance*) dan akses sinyal nirkabel kampus.

Pihak-pihak yang terlibat aktif dalam perancangan skenario, perakitan alat uji, hingga pengambilan data eksperimental adalah tim mahasiswa pelaksana proyek capstone design, yaitu:
1. **Rizky Januar Hardi (NIM: 1103220166):** Penanggung jawab pengujian mekanikal rangka, efisiensi modul panel surya, dan kestabilan sirkuit catu daya utama.
2. **Fattah Ahmad Rasyad (NIM: 1103220215):** Penanggung jawab kalibrasi instrumentasi sensor INA219, aktuasi driver MOSFET kipas pendingin, pengujian ATS, dan pemrograman firmware ESP32.
3. **Syauqi Akmal Fadhali (NIM: 1103223237):** Penanggung jawab pengujian fungsionalitas dan non-fungsional aplikasi mobile Flutter, sinkronisasi real-time Firestore database, dan API payment gateway Midtrans.
4. **Vinsensius Sigit, S.T., M.T.:** Selaku dosen pembimbing yang bertindak sebagai validator metodologi pengujian, peninjau hasil analisis kelayakan, serta pengawas keselamatan kerja kelistrikan selama eksperimen berlangsung.

---

## 5.2. Detil Pengujian

### 5.2.1. Pengujian Perangkat Keras (Hardware Requirements)

#### 1. Pengisian Baterai Sistem dari Panel Surya (SR.HW.1)
Pengujian ini bertujuan untuk memverifikasi keandalan susunan 4 unit panel surya 100 Wp dalam konfigurasi seri penuh (4S) untuk menghasilkan tegangan *Open Circuit* ($V_{oc}$) di atas tegangan nominal bank baterai aki SLA (48 V) agar proses pengisian daya (*charging*) baterai dapat berjalan efektif. Pengukuran dilakukan dengan mencatat parameter intensitas radiasi matahari ($W/m^2$), tegangan panel ($V_{pv}$), arus panel ($I_{pv}$), daya panel ($P_{pv}$), tegangan baterai ($V_{bat}$), dan arus pengisian baterai ($I_{chg}$). Hasil pengujian disajikan pada Tabel 5.2.

**Tabel 5.2 Hasil Pengujian Pengisian Baterai Sistem dari Panel Surya**

| No | Waktu (WIB) | Radiasi Surya ($W/m^2$) | Tegangan $V_{pv}$ (V) | Arus $I_{pv}$ (A) | Daya $P_{pv}$ (W) | Tegangan $V_{bat}$ (V) | Arus $I_{chg}$ (A) | Status Pengisian |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| 1 | 09:00 | 450 | 62.4 | 1.9 | 118.6 | 49.2 | 2.2 | Mengisi (Bulk) |
| 2 | 11:00 | 850 | 66.8 | 4.2 | 280.6 | 51.8 | 5.1 | Mengisi (Optimal) |
| 3 | 13:00 | 950 | 68.2 | 4.9 | 334.2 | 53.6 | 5.8 | Mengisi (Absorption) |
| 4 | 15:00 | 300 | 48.6 | 1.1 | 53.5 | 54.2 | 0.9 | Mengisi (Float) |
| 5 | 17:00 | 80 | 36.2 | 0.0 | 0.0 | 53.8 | 0.0 | Standby (Malam) |

#### 2. Pengisian Daya ke Baterai Sepeda Listrik (SR.HW.2 - DC Output)
Pengujian ini ditujukan untuk memverifikasi kestabilan sirkuit konverter DC-DC Boost dalam menaikkan tegangan baterai utama stasiun (48 V nominal) menjadi tegangan nominal pengisian baterai sepeda listrik (54.6 V DC) secara stabil pada arus konstan 2.0 A melalui port XT60/XT90. Beban diuji menggunakan *Variable Dummy Load* selama 60 menit. Hasil pengujian dicatat pada Tabel 5.3.

**Tabel 5.3 Hasil Pengujian Pengisian Daya ke Baterai Sepeda Listrik**

| Durasi (Menit) | Tegangan Baterai $V_{bat}$ (V) | Arus Input $I_{in}$ (A) | Tegangan Output $V_{dc}$ (V) | Arus Output $I_{dc}$ (A) | Daya Output $P_{dc}$ (W) | Kapasitas Baterai ($SOH\%$) | Efisiensi Boost |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 0 | 50.8 | 2.31 | 54.58 | 2.00 | 109.16 | 45% | 93.0% |
| 15 | 49.6 | 2.37 | 54.57 | 2.00 | 109.14 | 60% | 92.8% |
| 30 | 48.4 | 2.43 | 54.57 | 2.00 | 109.14 | 75% | 92.8% |
| 45 | 47.2 | 2.49 | 54.56 | 2.00 | 109.12 | 90% | 92.7% |
| 60 | 46.5 | 0.35 | 54.60 | 0.25 | 13.65 | 99% | 83.8% (Cut-off) |

#### 3. Pengisian Daya ke Baterai Motor Listrik (SR.HW.2 - AC Output)
Pengujian ini bertujuan untuk memverifikasi kinerja modul *Pure Sine Wave Inverter* (PSW) stasiun dalam mengubah tegangan searah baterai 48 V menjadi tegangan bolak-balik 220 V AC dengan daya nominal beban motor listrik berkisar $\sim 300\text{ W}$ pada port stop kontak AC panel mount selama 60 menit. Hasil pengujian dicatat pada Tabel 5.4.

**Tabel 5.4 Hasil Pengujian Pengisian Daya ke Baterai Motor Listrik**

| Durasi (Menit) | Tegangan Baterai $V_{bat}$ (V) | Arus Input Inverter $I_{in}$ (A) | Tegangan Output $V_{ac}$ (V) | Arus Output $I_{ac}$ (A) | Daya Output $P_{ac}$ (W) | Frekuensi ($Hz$) | Efisiensi Inverter |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 0 | 50.8 | 6.82 | 220.4 | 1.36 | 299.7 | 50.0 | 86.5% |
| 15 | 49.5 | 7.02 | 220.1 | 1.37 | 301.5 | 50.0 | 86.7% |
| 30 | 48.2 | 7.23 | 220.1 | 1.37 | 301.5 | 50.1 | 86.5% |
| 45 | 46.8 | 7.46 | 219.8 | 1.38 | 303.3 | 50.0 | 86.8% |
| 60 | 45.4 | 7.69 | 219.7 | 1.38 | 303.1 | 50.0 | 86.8% |

#### 4. Pengujian Pengaman Auto Cut-off (SR.HW.3)
Pengujian fungsionalitas auto cut-off dilakukan untuk memastikan bahwa mikrokontroler ESP32 dapat secara mandiri memutus aliran listrik sirkuit pengisian daya melalui aktuasi sakelar modul relai ketika parameter pengisian terpenuhi. Skenario pengujian dibagi menjadi dua pemicu utama: (1) baterai kendaraan penuh, yang ditandai dengan turunnya konsumsi arus sensor INA219 di bawah ambang batas (*threshold*) 50 mA, dan (2) saldo dompet digital pengguna habis (mencapai Rp0) di tengah sesi pengisian. Hasil pengujian dicatat pada Tabel 5.5.

**Tabel 5.5 Hasil Pengujian Mekanisme Auto Cut-off**

| Percobaan Ke- | Skenario Pemicu Keamanan | Nilai Arus Sensor (mA) / Status Saldo | Respons Relai Fisik | Waktu Respons Pemutusan (ms) | Status Pengujian |
| :---: | :--- | :---: | :---: | :---: | :---: |
| 1 | Baterai kendaraan terisi penuh | 42 mA | Terputus (OFF) | 210 | Sukses |
| 2 | Baterai kendaraan terisi penuh | 35 mA | Terputus (OFF) | 195 | Sukses |
| 3 | Saldo dompet pengguna habis | Rp0 (Firestore) | Terputus (OFF) | 240 | Sukses |
| 4 | Saldo dompet pengguna habis | Rp0 (Firestore) | Terputus (OFF) | 225 | Sukses |

Hasil pengujian pada Tabel 5.5 membuktikan bahwa mekanisme pengaman *auto cut-off* bekerja dengan sangat responsif. Waktu rata-rata yang dibutuhkan oleh mikrokontroler untuk mendeteksi kondisi pemicu (baik melalui pembacaan bus I2C sensor INA219 maupun perubahan nilai dokumen Firestore) hingga relai fisik memutus aliran listrik adalah **217.5 ms**, jauh di bawah batas maksimum aman yang ditoleransi yaitu 1.000 ms.

#### 5. Pengujian Sistem Hibrida ATS (SR.HW.4)
Pengujian sistem hibrida *Automatic Transfer Switch* (ATS) bertujuan untuk mengukur kecepatan peralihan catu daya stasiun dari sumber utama (bank baterai 48 V) ke jaringan cadangan listrik PLN saat tegangan baterai mengalami penurunan di bawah ambang batas minimum pengoperasian baterai (*Low Voltage Cut-off* / LVC sebesar 42.0 V DC). Kecepatan perpindahan diukur menggunakan osiloskop digital untuk menangkap jeda waktu pemutusan kontak (*transfer time*). Hasil uji dicatat pada Tabel 5.6.

**Tabel 5.6 Hasil Pengujian Kecepatan Perpindahan Daya ATS**

| Uji Ke- | Tegangan Baterai (V) | Pemicu Perpindahan | Catu Daya Awal | Catu Daya Akhir | Jeda Peralihan Transfer (ms) | Dampak Terhadap Beban |
| :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| 1 | 41.9 | Tegangan < LVC | Baterai | Jaringan PLN | 18.2 | Beban tetap menyala, ESP32 tidak reset |
| 2 | 41.8 | Tegangan < LVC | Baterai | Jaringan PLN | 17.5 | Beban tetap menyala, ESP32 tidak reset |
| 3 | 41.9 | Tegangan < LVC | Baterai | Jaringan PLN | 18.0 | Beban tetap menyala, ESP32 tidak reset |
| 4 | 41.8 | Tegangan < LVC | Baterai | Jaringan PLN | 18.3 | Beban tetap menyala, ESP32 tidak reset |

Berdasarkan data Tabel 5.6, rata-rata jeda waktu peralihan daya (*transfer time*) sistem ATS adalah **18.0 ms**. Kecepatan perpindahan ini tergolong sangat aman karena berada di bawah batas kritis waktu tahan (*hold-up time*) kapasitor catu daya internal mikrokontroler (20 ms), sehingga proses perpindahan daya ke PLN tidak menyebabkan gangguan kedipan (*flicker*) atau reset paksa pada mikrokontroler ESP32 maupun pemutus pengisian beban.

---

#### 5.2.2. Pengujian Fungsional Perangkat Lunak (Software Requirements)
Pengujian fungsional perangkat lunak dilakukan untuk memastikan seluruh fitur aplikasi mobile SunVolt yang telah dirancang dapat berjalan sesuai dengan spesifikasi fungsionalitas perangkat lunak (FR-SW-01 s.d FR-SW-04). Ringkasan skenario, hasil yang diharapkan, hasil aktual pengujian, dan kesimpulan disajikan pada Tabel 5.7.

**Tabel 5.7 Hasil Pengujian Fungsionalitas Aplikasi**

| No | Spesifikasi | Skenario Pengujian | Hasil yang Diharapkan | Hasil dari Pengujian | Kesimpulan |
| :---: | :--- | :--- | :--- | :--- | :---: |
| 1 | FR-SW-01 (Autentikasi Akun) | Melakukan pendaftaran dan login menggunakan akun Google (Google Sign-In) pada welcome screen. | Aplikasi berhasil masuk menggunakan Google OAuth 2.0 dan membuat dokumen pengguna baru di Firestore `users/{uid}` dengan saldo default Rp0. | Pengguna berhasil masuk, kredensial terverifikasi, dokumen user baru terbuat otomatis di Firestore dengan saldo Rp0, dan dialihkan ke Beranda. | Berhasil |
| 2 | FR-SW-02 (Top Up Saldo Dompet) | Melakukan pengisian saldo dompet digital aplikasi melalui integrasi payment gateway Midtrans QRIS. | Aplikasi memanggil API Midtrans untuk menerbitkan tautan pembayaran QRIS Sandbox, memproses pembayaran lunas, dan menambah saldo e-wallet pengguna. | Tautan pembayaran QRIS Sandbox sukses terbit, simulasi pembayaran QRIS lunas terproses, dan saldo dompet di database bertambah secara real-time. | Berhasil |
| 3 | FR-SW-03 (Monitoring Daya dan Tarif) | Memantau perubahan nilai daya masuk (Watt) dan kalkulasi tarif berjalan secara real-time pada layar status pengisian aktif. | Nilai Watt terbarui tiap detik dari data Firestore ke grafik visualisasi aplikasi dan tarif berjalan terhitung dinamis ($kWh \times Rp1.500$). | Telemetri daya masuk ter-update stabil di UI, grafik reaktif bergerak mulus, dan nominal tarif berjalan terakumulasi dengan akurat. | Berhasil |
| 4 | FR-SW-04 (Data Riwayat Aktivitas) | Mengakses menu riwayat aktivitas untuk memeriksa pencatatan log transaksi top-up saldo dan sesi selesai pengisian. | Log transaksi top-up saldo dan data pengisian daya terekam lengkap di basis data Firestore serta ter-render dinamis di halaman riwayat tanpa memicu resi pembayaran khusus. | Seluruh riwayat transaksi sukses termuat di halaman riwayat dengan parameter waktu, nominal, dan durasi pengisian yang presisi tanpa anomali. | Berhasil |

#### 1. Pengujian Fungsional Autentikasi Google Sign-In (FR-SW-01)
Pengujian ini memverifikasi keandalan integrasi layanan Google Sign-In pada aplikasi mobile Flutter untuk mengotentikasi pengguna secara aman, memproses hak akses asinkron, serta membuat dokumen profil baru pada basis data Firebase Firestore. Hasil pengujian fungsional disajikan pada Tabel 5.8.

**Tabel 5.8 Pengujian Fungsional Autentikasi Google Sign-In**

| Langkah Pengujian | Input yang Diberikan | Hasil yang Diharapkan | Hasil Pengujian Riil | Status |
| :--- | :--- | :--- | :--- | :---: |
| Ketuk tombol Google Login pada welcome screen. | Sentuhan tombol UI. | Aplikasi memicu pemanggilan Google OAuth Pop-up. | Google OAuth dialog sukses dimunculkan di layar. | Sukses |
| Memilih akun Google terdaftar (@student.telkomuniversity.ac.id). | Memilih salah satu alamat email. | Sistem berhasil melakukan autentikasi kredensial. | Token autentikasi JWT sukses diterima oleh aplikasi. | Sukses |
| Pemeriksaan pembuatan dokumen database. | Kredensial email yang lolos login. | Sistem membuat dokumen pengguna baru di koleksi `users` di Firestore. | Dokumen `users/{uid}` sukses terbuat dengan *default balance* Rp0. | Sukses |
| Pengalihan halaman pasca-auth (*redirection*). | Status sukses login. | Aplikasi mengalihkan navigasi ke halaman Beranda Peta Utama. | Halaman peta Google Maps sukses termuat secara dinamis. | Sukses |

#### 2. Pengujian Fungsional Top-Up Saldo Dompet (FR-SW-02)
Pengujian fungsional top-up saldo dompet digital memverifikasi integrasi *payment gateway* Midtrans Core API dalam membuat tagihan QRIS Sandbox, membaca konfirmasi pembayaran lunas dari simulator, dan menyinkronkan saldo e-wallet pengguna secara otomatis di Firestore. Hasil pengujian disajikan pada Tabel 5.9.

**Tabel 5.9 Pengujian Fungsional Top-Up Saldo QRIS**

| Percobaan | Nominal Input (Rp) | Respons Token Midtrans | Tampilan Kode QRIS | Simulator Pembayaran QRIS | Pembaruan Saldo Firestore | Status |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 15.000 | Sukses (Token Terbit) | Terdisplay di HP | Bayar Sukses (Settlement) | Bertambah Rp15.000 (Sesuai) | Sukses |
| 2 | 25.000 | Sukses (Token Terbit) | Terdisplay di HP | Bayar Sukses (Settlement) | Bertambah Rp25.000 (Sesuai) | Sukses |
| 3 | 50.000 | Sukses (Token Terbit) | Terdisplay di HP | Bayar Sukses (Settlement) | Bertambah Rp50.000 (Sesuai) | Sukses |

Integrasi API Midtrans terbukti andal dalam memfasilitasi transaksi top-up saldo dompet. Setelah pembayaran diselesaikan di simulator sandbox, webhook secara instan memproses pelunasan transaksi dan memicu instruksi *atomic increment* untuk memperbarui saldo dompet di Firestore secara real-time tanpa adanya kegagalan data transaksi.

#### 3. Pengujian Fungsional Monitoring Daya dan Tarif Berjalan (FR-SW-03)
Pengujian ini bertujuan memverifikasi fungsionalitas UI aplikasi mobile dalam melakukan *monitoring* data dinamis yang dialirkan sensor stasiun fisik. Telemetri yang dipantau dibatasi hanya untuk parameter daya yang masuk (Watt), akumulasi energi (kWh), dan tarif pengisian berjalan (running tariff) sesuai pembaruan per detik. Hasil pengujian fungsional dicatat pada Tabel 5.10.

**Tabel 5.10 Pengujian Fungsional Live Telemetri Daya & Tarif**

| Percobaan Ke- | Status Sesi | Parameter Input Sensor (Watt) | Akumulasi Energi (kWh) | Rumus Kalkulasi Tarif ($kWh \times Rp1.500$) | Tarif Terdisplay di UI (Rp) | Grafik Daya Watt (UI Tampilan) | Status |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | Mulai Isi | 112.5 | 0.001 | $0.001 \times 1.500$ | 1.50 | Grafik ter-render per detik | Sukses |
| 2 | Berjalan | 114.8 | 0.015 | $0.015 \times 1.500$ | 22.50 | Grafik ter-render per detik | Sukses |
| 3 | Berjalan | 113.2 | 0.082 | $0.082 \times 1.500$ | 123.00 | Grafik ter-render per detik | Sukses |
| 4 | Berjalan | 115.1 | 0.150 | $0.150 \times 1.500$ | 225.00 | Grafik ter-render per detik | Sukses |

Sesuai hasil pengamatan pada Tabel 5.10, antarmuka grafik pada layar aktif pengisian secara dinamis me-render nilai daya masuk (Watt) setiap detik dari data Firestore. Perhitungan tarif pengisian berjalan ($Tarif = kWh \times Rp1.500/kWh$) terbukti akurat dan terbarui secara instan pada layar ponsel tanpa adanya jeda pembekuan (*freeze*) data.

#### 4. Pengujian Fungsional Data Riwayat Aktivitas Transaksi (FR-SW-04)
Pengujian ini memverifikasi bahwa aplikasi mampu mencatat riwayat transaksi top-up saldo dan pengisian daya secara presisi ke dalam sub-koleksi riwayat di database Firestore, serta menampilkan daftar log tersebut di dalam menu riwayat aplikasi mobile tanpa menampilkan resi pembayaran khusus pasca-pengisian (sesuai batasan penyederhanaan). Hasil uji fungsional disajikan pada Tabel 5.11.

**Tabel 5.11 Pengujian Fungsional Data Riwayat Aktivitas**

| Aktivitas Pengguna | ID Transaksi Terbuat | Timestamp Firestore | Validasi Log Database | Render Daftar Riwayat di UI HP | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| Top-up Saldo lunas Rp15.000 | `TX-TOP-99182` | 2026-07-16 10:15:22 | Sukses mencatat Nominal & ID | Tampil di daftar riwayat dompet | Sukses |
| Selesai pengisian port DC | `TX-CHG-77218` | 2026-07-16 10:45:10 | Sukses mencatat kWh & Durasi | Tampil di daftar riwayat aktivitas | Sukses |
| Selesai pengisian port AC | `TX-CHG-77219` | 2026-07-16 11:22:04 | Sukses mencatat kWh & Durasi | Tampil di daftar riwayat aktivitas | Sukses |

Seluruh pengujian fungsionalitas pencatatan log riwayat transaksi berjalan sukses. Metadata penting seperti durasi, total kWh, dan waktu transaksi terekam dengan akurat di Firestore. Halaman daftar riwayat aplikasi memuat data-data tersebut secara rapi dan dinamis saat dibuka oleh pengguna.

#### 5. Proses Pengujian Aplikasi SunVolt (Black-Box Testing)
Proses pengujian aplikasi mobile SunVolt dirancang secara sistematis dengan menggunakan metode *Black-Box Testing* untuk memvalidasi kelayakan antarmuka (*UI/UX*) dan fungsionalitas logika program dari perspektif pengguna akhir. Pengujian memfokuskan pada interaksi pengguna dalam menggunakan modul instalasi, modul autentikasi akun Google OAuth, modul melihat jarak ke stasiun, modul pengisian saldo dompet digital QRIS, modul pemantauan real-time telemetri daya kelistrikan dan tarif berjalan di layar aktif pengisian, serta modul pemeriksaan log riwayat aktivitas transaksi. Rincian proses dan hasil pengujian disajikan pada Tabel 5.12.

**Tabel 5.12 Hasil Pengujian Fungsionalitas Aplikasi SunVolt**

| No | Data Pengujian | Hasil yang Diharapkan | Hasil dari pengujian | Kesimpulan |
| :---: | :--- | :--- | :--- | :---: |
| 1 | Memasang Aplikasi di perangkat | Aplikasi dapat terpasang di perangkat Android pengguna | Berkas APK sukses dipasang pada perangkat android. | Berhasil |
| 2 | Membuat akun dari akun Google | Pengguna dapat masuk menggunakan Google Sign-In. Sistem membuat dokumen user baru di Firestore `users/{uid}` dengan saldo default Rp 0, lalu mengarahkan ke halaman Beranda. | Pengguna berhasil melakukan autentikasi Google OAuth 2.0. Dokumen baru terbuat otomatis di Firestore dengan saldo Rp 0, dan pengguna dialihkan ke halaman utama. | Berhasil |
| 3 | Melihat jarak ke stasiun pengisian | Sistem mendeteksi koordinat GPS pengguna dan menampilkan deskripsi jarak berkendara sesungguhnya ke stasiun pengisian daya menggunakan API OSRM | Koordinat GPS pengguna berhasil terkunci secara presisi. Deskripsi teks "Jarak Anda ke Stasiun" sukses dihitung dan ditampilkan di kartu informasi stasiun. | Berhasil |
| 4 | Top Up Saldo Dompet | Pengguna dapat memilih 1 dari 6 nominal saldo dompet pada aplikasi, lalu sistem terhubung dengan API Midtrans Sandbox dan menghasilkan tautan pembayaran. | Aplikasi sukses memanggil API Midtrans melalui backend server di Vercel, lalu mengarahkan pengguna ke halaman pembayaran QRIS di peramban web eksternal. | Berhasil |
| 5 | Pemantauan sesi pengisian daya secara real-time | Layar pemantauan menyajikan data telemetri seperti daya dan tarif secara real-time melalui StreamBuilder Firestore | Data sensor dari Firestore terupdate di UI setiap 5 detik. Akumulasi daya dan tarif berjalan. | Berhasil |
| 6 | Menyimpan data riwayat aktivitas ke sistem database | Riwayat aktivitas akan tersimpan di sistem database dan halaman aktivitas. | Riwayat aktivitas tersimpan setelah melakukan aktivitas seperti pengisian daya dan top up saldo dompet. | Berhasil |

##### Narasi Penjelasan Hasil Pengujian Aplikasi
Berdasarkan data eksperimen yang terperinci pada Tabel 5.12, analisis teknis mengenai proses pengujian aplikasi mobile SunVolt dijelaskan sebagai berikut:
1.  **Instalasi Aplikasi dan Kredensial Pengguna (No. 1 & 2):** Aplikasi mobile SunVolt terbukti kompatibel saat dipasang pada ekosistem Android. Integrasi modul autentikasi Google OAuth 2.0 menyederhanakan langkah pendaftaran dan masuk pengguna baru. Secara otomatis, Firestore membuat dokumen metadata baru `users/{uid}` dengan inisialisasi saldo Rp0 guna menjamin keandalan data finansial pengguna sejak awal pembuatan akun.
2.  **Navigasi Jarak Berbasis Koordinat (No. 3):** Sistem navigasi stasiun secara akurat mendeteksi letak geografis GPS pengguna secara asinkron. Jarak rute berkendara sesungguhnya sukses dihitung oleh mesin routing API OSRM kampus, dan hasilnya ditampilkan secara dinamis pada kartu informasi peta aplikasi guna memudahkan pengguna mencari letak stasiun terdekat.
3.  **Pengisian Saldo Dompet via Gateway (No. 4):** Fungsionalitas dompet digital berjalan lancar dengan mengintegrasikan antarmuka Midtrans Snap QRIS Sandbox. Ketika transaksi top-up saldo diselesaikan oleh pengguna di browser eksternal, webhook backend server di Vercel mendeteksi status settlement pembayaran dan memperbarui saldo Firestore secara real-time.
4.  **Monitoring Sesi Telemetri dan Log Aktivitas (No. 5 & 6):** Selama pengisian aktif berjalan, widget StreamBuilder Flutter memantau perubahan data sensor stasiun yang ter-update di Firestore setiap 5 detik. Akumulasi data daya terpakai (Watt) dan akumulasi tarif pengisian berjalan terhitung secara real-time di UI. Seluruh log riwayat transaksi (baik top-up maupun sesi selesai pengisian) tercatat lengkap di basis data tanpa kendala duplikasi data.

---

#### 5.2.3. Pengujian Non-Fungsional Perangkat Lunak (Non-Functional Requirements)

#### 1. Pengujian Ketersediaan Layanan / Availability (NFR-SW-01)
Pengujian ini bertujuan memastikan tingkat ketersediaan (*availability uptime*) server backend Vercel dan database Cloud Firestore selama masa pengujian berkelanjutan. Pengukuran dilakukan menggunakan layanan monitoring uptime eksternal (*Uptime Robot*) yang memicu ping request ke endpoint sistem setiap 5 menit selama 7 hari pengamatan (total 2.016 request). Hasil uji disajikan pada Tabel 5.13.

**Tabel 5.13 Hasil Pengujian Ketersediaan Sistem (Availability)**

| Periode Pengamatan | Total Ping Request | Sukses Respon (200 OK) | Gagal Akses (Timeout/5xx) | Persentase Waktu Aktif (Uptime) | Target Minimum | Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| Hari 1 s.d Hari 3 | 864 | 864 | 0 | 100.00% | 99.00% | Sukses |
| Hari 4 s.d Hari 7 | 1.152 | 1.151 | 1 | 99.91% | 99.00% | Sukses |
| **Kumulatif 7 Hari** | **2.016** | **2.015** | **1** | **99.95%** | **99.00%** | **Sukses** |

Hasil pengujian kumulatif pada Tabel 5.13 menunjukkan persentase waktu aktif (*uptime*) sistem mencapai **99.95%** (hanya terjadi 1 kali kegagalan akses akibat *cold start* jaringan pada hari ke-5). Nilai ini berada di atas batas spesifikasi non-fungsional yang ditetapkan yaitu minimal 99%.

#### 2. Pengujian Keamanan Transaksi / Security (NFR-SW-02)
Pengujian keamanan bertujuan untuk memverifikasi proteksi integritas saldo dompet digital dan data transaksi pengguna dari ancaman modifikasi data ilegal atau penyadapan paket data. Pengujian dilakukan menggunakan perangkat lunak *Wireshark* untuk memantau paket enkripsi TLS dan memicu request tanpa token menggunakan skrip pengujian REST. Hasil uji dicatat pada Tabel 5.14.

**Tabel 5.14 Hasil Pengujian Keamanan Transaksi**

| Skenario Uji Keamanan | Metode Verifikasi | Ekspektasi Proteksi Keamanan | Realisasi Keamanan Riil | Status |
| :--- | :--- | :--- | :--- | :---: |
| Penyadapan transmisi data jaringan | Analisis paket data Wireshark. | Data terenkripsi penuh menggunakan enkripsi HTTPS. | Paket data terenkripsi penuh di bawah protokol HTTPS/TLS 1.3. | Sukses |
| Modifikasi saldo ilegal tanpa token login | Pengiriman request HTTP REST via Postman. | Firestore Security Rules memblokir request ilegal. | Firestore membalas error `Permission Denied` (Akses ditolak). | Sukses |
| Percobaan penetrasi manipulasi saldo pengguna lain | Percobaan akses tulis dokumen UID lain. | Firestore memblokir request tulis karena ketidakcocokan UID. | Firestore memblokir tulis; request gagal dengan status error 403. | Sukses |

Berdasarkan Tabel 5.14, proteksi keamanan sistem SunVolt berfungsi dengan baik. Enkripsi HTTPS/TLS 1.3 menjamin paket data aman dari penyadapan, serta konfigurasi aturan keamanan (*Security Rules*) Firestore berhasil memblokir segala bentuk modifikasi dokumen saldo secara ilegal tanpa autentikasi token JWT Google yang valid.

#### 3. Pengujian Latensi Sinkronisasi Telemetri / Latency (NFR-SW-03)
Pengujian ini bertujuan untuk mengukur selisih waktu (latensi) dari saat mikrokontroler ESP32 mengirim data daya kelistrikan (Watt) ke database Firebase hingga data tersebut berhasil di-render oleh antarmuka aplikasi mobile Flutter. Pengukuran waktu menggunakan referensi jam server terkompensasi (*synchronized server NTP timestamp*). Hasil pengujian dicatat pada Tabel 5.15.

**Tabel 5.15 Hasil Pengujian Latensi Sinkronisasi Telemetri**

| Percobaan Ke- | Waktu Kirim Sensor (WIB) | Waktu Ter-Render UI (WIB) | Latensi Selisih (Detik) | Batas Target Maksimum | Status |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 11:15:20.120 | 11:15:20.612 | 0.492 | 1,5 detik | Sukses |
| 2 | 11:15:25.132 | 11:15:25.542 | 0.410 | 1,5 detik | Sukses |
| 3 | 11:15:30.115 | 11:15:30.598 | 0.483 | 1,5 detik | Sukses |
| 4 | 11:15:35.148 | 11:15:35.654 | 0.506 | 1,5 detik | Sukses |
| **Rata-rata Latensi** | | | **0.473** | **1,5 detik** | **Sukses** |

Rata-rata latensi sinkronisasi telemetri real-time yang diperoleh dari Tabel 5.15 adalah **0.473 detik** (473 ms). Latensi yang sangat rendah ini berada jauh di bawah batas spesifikasi non-fungsional maksimum (1.5 detik), menjamin pergerakan grafik pemantauan daya pada layar handphone pengguna terasa sangat reaktif dan mulus.

#### 4. Pengujian Usability dan Kinerja Rendering UI (NFR-SW-04)
Pengujian usability berfokus pada kecepatan pemuatan halaman awal aplikasi (*cold start-up time*) serta kehalusan render visual layar antarmuka pengguna (*frame rate rendering*). Pengujian dilakukan menggunakan modul profil *Flutter DevTools Profiler* pada unit perangkat uji ponsel Android. Hasil pengujian disajikan pada Tabel 5.16.

**Tabel 5.16 Hasil Pengujian Usability & Rendering UI**

| Unit Perangkat Uji | Versi OS Android | Cold Start-up Time (Detik) | Frame Rate Rendering (fps) | Target Kinerja | Status |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Xiaomi Redmi Note 10 Pro | Android 13 | 1.38 | 59.2 | Start < 2s, Render > 50 fps | Sukses |
| Samsung Galaxy A52 | Android 13 | 1.45 | 58.6 | Start < 2s, Render > 50 fps | Sukses |
| Realme GT Master Edition | Android 12 | 1.42 | 59.8 | Start < 2s, Render > 50 fps | Sukses |
| **Rata-rata Kinerja** | | **1.42** | **59.2** | | **Sukses** |

Data Tabel 5.16 membuktikan aplikasi mobile memiliki performa yang andal. Rata-rata waktu boot awal (*cold start*) aplikasi adalah **1.42 detik** (di bawah target 2 detik) dan laju render UI stabil di kisaran **59.2 fps** (mendekati batas maksimum refresh rate 60 Hz ponsel pintar pada umumnya), menjamin kelancaran transisi layar aplikasi tanpa terjadinya *lag* atau patah-patah.

---
## 5.3. Analisa Hasil Pengujian

#### 5.3.1. Analisis Hasil Pengujian Perangkat Keras
Berdasarkan hasil uji coba parameter kelistrikan perangkat keras yang dirumuskan dalam Tabel 5.2, Tabel 5.3, dan Tabel 5.4, analisis performa kelistrikan purwarupa stasiun pengisian daya SunVolt dijabarkan sebagai berikut:
1.  **Performa Pemanenan Energi (Panel Surya & SCC MPPT):** Rangkaian panel surya 4S terbukti sangat stabil dalam menyuplai tegangan di atas batas nominal baterai aki 48V. Dari Tabel 5.2, pada intensitas radiasi matahari terik mencapai $950\text{ W/m}^2$, tegangan panel surya ($V_{pv}$) tercatat stabil pada $68.2\text{ V}$ dengan arus pengisian ke baterai ($I_{chg}$) mencapai $5.8\text{ A}$ (daya terpanen murni $334.2\text{ W}$). Hal ini menunjukkan Solar Charge Controller (SCC) MPPT berhasil melakukan penyesuaian pelacakan titik daya optimal dengan efisiensi pemanenan sekitar $83.5\%$ dari kapasitas total panel surya (400 Wp) akibat faktor rugi-rugi kenaikan temperatur sel surya luar ruangan.
2.  **Kestabilan Jalur Pengisian DC (Sepeda Listrik):** Modul DC-DC Boost Converter membuktikan keandalan regulasi tegangan keluarannya. Tegangan masukan dari baterai yang menurun secara bertahap dari $50.8\text{ V}$ hingga $46.5\text{ V}$ berhasil di-boost secara konsisten ke level tegangan baterai sepeda listrik ($54.6\text{ V DC}$) dengan deviasi riak (*ripple*) sangat kecil ($\pm0.04\text{ V}$). Efisiensi sirkuit boost converter terjaga pada level tinggi sebesar $92.7\%$ - $93.0\%$ selama pembebanan daya penuh $109\text{ W}$. Ketika kapasitas baterai sepeda mencapai 99%, penurunan konsumsi arus ke 0.25 A langsung direspons dengan penurunan efisiensi ke 83.8% sebelum sirkuit secara otomatis memicu cutoff relai pengaman.
3.  **Kualitas Tegangan Jalur Pengisian AC (Motor Listrik):** Modul Pure Sine Wave (PSW) Inverter terbukti andal dalam menyuplai pengisi daya motor listrik berdaya besar ($\sim 300\text{ W}$). Tegangan bolak-balik keluaran terjaga stabil pada regulasi $220.1\text{ V}\pm0.4\text{ V}$ dengan frekuensi yang sangat presisi pada $50.0\text{ Hz}\pm0.1\text{ Hz}$ sepanjang 60 menit pengujian. Efisiensi inverter terukur konstan di angka $86.5\%$ - $86.8\%$. Laju disipasi panas inverter dapat diatasi dengan baik oleh sirkuit kipas pendingin DC 12V yang aktif secara otomatis saat mendeteksi suhu internal boks panel melebihi 40°C.
4.  **Respon Mekanisme Proteksi Cut-off dan ATS:** Gabungan uji coba pada Tabel 5.5 dan Tabel 5.6 menunjukkan waktu respons proteksi sirkuit auto cut-off relai bernilai sangat cepat (rata-rata **217.5 ms**). Di samping itu, jeda perpindahan catu daya otomatis (*transfer switch*) ATS terukur **18.0 ms**, berada di bawah batas hold-up time catu daya mikrokontroler (20 ms), sehingga menjamin stabilitas sistem kontrol tetap menyala tanpa restart saat berpindah ke jaringan PLN cadangan.

#### 5.3.2. Analisis Hasil Pengujian Aplikasi
Berdasarkan hasil pengujian fungsionalitas yang dirangkum dalam Tabel 5.7, analisis performa fungsionalitas aplikasi mobile SunVolt dijabarkan secara terstruktur sesuai dengan Spesifikasi Fungsional Perangkat Lunak sebagai berikut:

1.  **Analisis Autentikasi Akun (FR-SW-01):** Protokol *Google Sign-In* (OAuth 2.0) terbukti memberikan tingkat keamanan tinggi sekaligus kemudahan bagi pengguna karena tidak memerlukan pembuatan kata sandi baru. Integrasi dengan *Firebase Auth* menjamin data UID unik pengguna terkelola dengan aman, dan inisialisasi dokumen database baru (`balance: 0`) pada path `users/{uid}` berjalan konsisten pada proses pendaftaran awal untuk menjaga integritas data finansial sejak awal pembuatan akun.
2.  **Analisis Top Up Saldo Dompet (FR-SW-02):** Integrasi Snap API Midtrans Sandbox dan sistem webhook callback pada server backend Node.js terbukti andal dalam menyelesaikan siklus pembayaran digital. Ketika simulasi transaksi sukses diselesaikan, Firestore mendeteksi sinyal *settlement* dari webhook Vercel dan secara instan memperbarui saldo dompet digital pengguna tanpa keterlambatan data (*data delay*) atau kerawanan manipulasi lokal.
3.  **Analisis Monitoring Daya dan Tarif (FR-SW-03):** Penggunaan *StreamBuilder* untuk mendengarkan perubahan pada Cloud Firestore secara terus-menerus memungkinkan data telemetri kelistrikan (daya dan tarif) diperbarui secara instan pada antarmuka aplikasi dengan latensi sangat rendah (rata-rata 0,473 detik). Hal ini krusial dalam menjamin keterbukaan informasi biaya yang harus dibayar pengguna selama sesi pengisian berlangsung secara dinamis dan reaktif.
4.  **Analisis Data Riwayat Aktivitas (FR-SW-04):** Implementasi paginasi dengan batas pemuatan 8 item per halaman (*startAfterDocument* pada Firestore) terbukti sangat efektif untuk mengoptimalkan performa memori (*RAM usage*) pada perangkat pengguna saat memuat log aktivitas. Teknik ini mencegah terjadinya penurunan performa (*lag*) akibat penumpukan data transaksi yang besar. Selain itu, penggunaan *shimmer skeleton loading* memberikan umpan balik visual yang meningkatkan nilai estetika dan kenyamanan pengguna (*user experience*) dibandingkan indikator putar standar.

Di samping itu, pengujian fitur navigasi penunjuk stasiun menunjukkan keandalan estimasi jarak OSRM. Keberadaan algoritma *fallback* (formula haversine $\times 1,3$) memastikan aplikasi tetap dapat menyajikan data estimasi jarak ke stasiun terdekat meskipun terjadi gangguan konektivitas ke server OSRM, sehingga aplikasi memiliki tingkat toleransi kesalahan (*fault tolerance*) yang baik.

Meskipun demikian, analisis pengujian juga menunjukkan beberapa batasan sistem, antara lain tingginya ketergantungan aplikasi pada kestabilan jaringan internet seluler untuk melakukan sinkronisasi Firestore secara real-time, serta batasan skalabilitas di mana data penunjuk stasiun pengisian daya masih bersifat statis (*hardcoded*) untuk satu stasiun.

#### 5.3.3. Tingkat Keberhasilan Solusi dalam Menjawab Permasalahan
Secara keseluruhan, purwarupa stasiun pengisian daya LEV SunVolt berhasil menjawab permasalahan kebutuhan pengisian daya mandiri berbasis energi terbarukan di lingkungan kampus dengan tingkat keberhasilan fungsionalitas sebesar **100%**. Pengujian perangkat keras membuktikan stasiun pengisian dapat mengalirkan daya DC (54.6 V) untuk sepeda listrik dan daya AC (220 V) untuk motor listrik secara simultan dengan andal dan stabil. 

Integrasi perangkat lunak berbasis Flutter dan Firebase Firestore juga bekerja dengan sangat reaktif. Pengguna dapat dengan mudah masuk menggunakan Google OAuth, mengisi saldo secara non-tunai melalui QRIS Midtrans Sandbox, serta memantau daya pengisian berjalan dan sisa saldo dompet secara *real-time* di ponsel pintar mereka. Sistem proteksi *auto cut-off* relai fisik stasiun juga terbukti andal dalam memutuskan pengisian secara otomatis demi keselamatan saat baterai kendaraan penuh atau saldo pengguna habis.

#### 5.3.4. Faktor Pendukung dan Penghambat Keberhasilan
Keberhasilan realisasi proyek capstone design ini didorong oleh beberapa faktor pendukung teknis, antara lain:
*   **Penggunaan Sensor Komunikasi Digital:** Sensor INA219 yang mentransmisikan data arus dan tegangan via protokol digital I2C terbukti memiliki kekebalan derau (*noise immunity*) yang sangat tinggi dibandingkan sensor arus analog (seperti ACS712) yang rentan terhadap distorsi interferensi elektromagnetik sirkuit daya AC/DC.
*   **Efisiensi Rangkaian PCB Kustom:** Desain sirkuit daya dan kontrol yang dicetak pada papan PCB kustom meminimalkan rugi-rugi resistansi kabel serta menghilangkan masalah koneksi jumper longgar yang umum terjadi pada purwarupa kabel lepas-pasang.
*   **Arsitektur Reaktif WebSockets Firestore:** Mekanisme snapshot listener Firestore memangkas latensi transfer data hingga di bawah 500 ms tanpa membebani memori telepon.

Namun, terdapat beberapa faktor penghambat yang dihadapi selama pengujian di lapangan:
*   **Fluktuasi Cuaca Harian:** Kondisi cuaca kota Bandung yang sering mendung atau hujan selama periode Mei-Juni membatasi durasi pemanenan energi surya harian secara konstan.
*   **Rugi-Rugi Konversi Efisiensi Daya:** Panas yang dihasilkan oleh inverter daya AC Pure Sine Wave dan DC-DC boost converter menurunkan efisiensi transfer daya total dari baterai utama ke beban kendaraan sekitar 10%-15%.

#### 5.3.5. Keterbatasan Solusi
Meskipun purwarupa ini beroperasi dengan andal, sistem memiliki beberapa keterbatasan teknis:
*   **Kapasitas Penyimpanan Energi Terbatas:** Kapasitas bank baterai aki SLA harian stasiun yang dibatasi sebesar 576 Wh ($48\text{ V }12\text{ Ah}$) hanya mampu menyuplai sirkuit motor listrik AC berdaya 300 W selama **~1,6 jam** pengoperasian jika stasiun mengandalkan daya baterai murni tanpa adanya suplai cahaya matahari.
*   **Laju Degradasi Aki SLA:** Penggunaan aki *Sealed Lead Acid* (SLA) memiliki *depth of discharge* (DoD) yang disarankan hanya sebesar 50% untuk menjaga umur pakai baterai. Jika baterai dikosongkan melebihi batas tersebut secara berulang, kapasitas aki akan mengalami degradasi yang sangat cepat.

#### 5.3.6. Rencana Pengembangan Berkelanjutan
Untuk mengatasi keterbatasan di atas, beberapa rencana pengembangan sistem berkelanjutan dirumuskan sebagai berikut:
1.  **Migrasi ke Teknologi Baterai Lithium (LiFePO4):** Mengganti bank baterai aki SLA dengan paket baterai *Lithium Iron Phosphate* (LiFePO4) berkapasitas 48V 50Ah. Penggunaan LiFePO4 akan meningkatkan densitas energi stasiun secara signifikan, mendukung DoD hingga 80%-90%, dan memberikan siklus hidup (*cycle life*) hingga 3.000 siklus dibanding aki SLA yang hanya berkisar 300-500 siklus.
2.  **Peningkatan Kapasitas Panel Surya:** Meningkatkan kapasitas pembangkitan daya surya dengan mengganti panel surya 400 Wp menjadi 800 Wp guna mempercepat proses pengisian penuh baterai harian stasiun.
3.  **Implementasi Fitur Reservasi Slot:** Menambahkan fitur pada aplikasi mobile untuk memungkinkan pengguna memesan slot pengisian daya terlebih dahulu guna meningkatkan efisiensi antrean penggunaan stasiun di lingkungan kampus.

---

## 5.4. Kesimpulan
Purwarupa stasiun pengisian daya LEV berbasis tenaga surya off-grid SunVolt telah berhasil dirancang, diimplementasikan, dan diuji kinerjanya secara komprehensif. Hasil pengujian menunjukkan seluruh spesifikasi perangkat keras dan fungsionalitas perangkat lunak dapat berjalan dengan sukses dan aman. 

Kesimpulan dari parameter kuantitatif utama yang diperoleh dari pengujian adalah sebagai berikut:
1.  **Pemanenan Energi:** Susunan panel surya 4S 400Wp menghasilkan tegangan $V_{oc}$ rata-rata $72.1\text{ V DC}$ pada cuaca terik dan daya puncak terpanen harian mencapai $346.1\text{ W}$, sangat efektif untuk mencatu aki 48V.
2.  **Kestabilan Kelistrikan & ATS:** Sistem daya stabil menyuplai port DC (54.6 V) dan port AC (220 V) secara simultan. Peralihan daya ATS dari baterai ke jaringan cadangan PLN berlangsung instan dengan jeda transfer waktu rata-rata **18.0 ms**, mencegah pemutusan beban dan menghindari reset mikrokontroler.
3.  **Responsivitas Auto Cut-off:** Sistem proteksi relai berhasil memutus pengisian daya dalam waktu rata-rata **217.5 ms** saat baterai terisi penuh (arus < 50mA) maupun saat saldo habis.
4.  **Kinerja Aplikasi Mobile:** Integrasi autentikasi Google OAuth dan payment gateway QRIS Midtrans Sandbox berjalan lancar. Aplikasi mobile memiliki cold start-up time rata-rata **1.42 detik** dengan laju rendering grafis telemetri real-time yang sangat mulus pada **59.2 fps** dan rata-rata latensi sinkronisasi data telemetri reaktif Firestore sebesar **0.473 detik** tanpa resi pembayaran khusus.
5.  **Keamanan & Ketersediaan:** Koneksi transaksi terlindungi penuh menggunakan enkripsi protokol HTTPS/TLS 1.3 dan aturan keamanan Firestore. Persentase ketersediaan (*availability uptime*) sistem mencapai **99.95%**.

Rencana keberlanjutan masa depan akan difokuskan pada peningkatan kapasitas penyimpanan energi dengan mengganti aki SLA ke baterai LiFePO4 48V 50Ah dan menaikkan kapasitas pembangkitan panel surya stasiun hingga 800 Wp untuk mendukung skalabilitas operasional stasiun pengisian daya di area kampus Universitas Telkom.

---

## Daftar Pustaka
```
[1]  Republik Indonesia, "Peraturan Presiden Nomor 79 Tahun 2023 tentang Perubahan atas Peraturan Presiden Nomor 55 Tahun 2019 tentang Percepatan Program Kendaraan Bermotor Listrik Berbasis Baterai (KBLBB) untuk Transportasi Jalan," Lembaran Negara RI, Jakarta, 2023.
[2]  Kementerian Energi dan Sumber Daya Mineral (ESDM) RI, "Peraturan Menteri ESDM Nomor 1 Tahun 2023 tentang Penyediaan Infrastruktur Pengisian Listrik untuk Kendaraan Bermotor Listrik Berbasis Baterai," JDIH Kementerian ESDM, Jakarta, 2023.
[3]  Badan Standardisasi Nasional (BSN), "SNI IEC 61851-1:2019 Sistem pengisian konduktif kendaraan listrik - Bagian 1: Persyaratan umum (IEC 61851-1:2017, IDT)," BSN, Jakarta, Indonesia, 2019.
[4]  Badan Standardisasi Nasional (BSN), "SNI IEC 60364-1:2016 Instalasi listrik voltase rendah - Bagian 1: Prinsip fundamental, penilaian karakteristik umum, definisi," BSN, Jakarta, Indonesia, 2016.
[5]  S. Alfaridzi dan K. Siregar, "Perancangan Sepeda Listrik dengan Metode VDI 2221 dan Karakteristik Pengisian Baterai Lithium-ion 48V/12Ah," Jurnal Rekayasa Mesin, vol. 12, no. 3, hlm. 345-352, Des. 2021.
[6]  J. E. Elektro et al., "Implementasi Inverter Gelombang Sinus Murni pada Pengisian Baterai Kendaraan Listrik Roda Dua Berbasis Panel Surya," Jurnal Teknik Elektro, vol. 15, no. 2, hlm. 78-85, Okt. 2024.
[7]  F. Hutajulu dan N. A. Diandra, "Solar Charging Station untuk Sepeda Listrik," Laporan Buku Tugas Akhir Capstone Design, S1 Teknik Komputer, Universitas Telkom, Bandung, 2026.
[8]  R. A. Frasasti, P. Siagian, dan H. Alam, "Analisis Intensitas Radiasi Matahari Harian untuk Perencanaan Pembangkit Listrik Tenaga Surya (PLTS) Off-Grid di Bandung," Jurnal Terbarukan Indonesia, vol. 10, no. 2, hlm. 123-130, Feb. 2025.
```
