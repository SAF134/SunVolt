# DOKUMEN CD-4: IMPLEMENTASI
## SISTEM PENGISIAN DAYA KENDARAAN LISTRIK RINGAN BERBASIS TENAGA SURYA

---

## 1.1. Diskripsi Umum Implementasi
Implementasi merupakan tahap realisasi dari hasil perancangan sistem yang telah dilakukan pada dokumen sebelumnya. Pada tahap ini, seluruh rancangan perangkat keras dan perangkat lunak diintegrasikan menjadi sebuah *prototype* stasiun pengisian daya kendaraan listrik ringan berbasis tenaga surya yang dapat bekerja sesuai dengan kebutuhan operasional. Sistem dirancang untuk menyediakan fasilitas pengisian daya mandiri bagi sepeda listrik dan sepeda motor listrik yang ramah lingkungan.

*Prototype* yang dikembangkan pada penelitian ini berupa stasiun pengisian daya pintar terintegrasi. Sistem memiliki fitur utama berupa pengisian daya yang bersumber dari energi matahari, sistem pengaman darurat, serta pendingin internal boks yang dapat dipantau dan dikendalikan dari jarak jauh melalui dasbor web admin.

Lingkungan kampus memiliki mobilitas civitas akademika yang tinggi dengan tren penggunaan sepeda dan motor listrik yang terus meningkat. Namun, keterbatasan fasilitas pengisian daya khusus sering kali membuat pengguna kesulitan dan terpaksa bergantung pada sumber listrik konvensional. Oleh karena itu, dibutuhkan sebuah sistem pengisian daya mandiri yang memanfaatkan energi terbarukan agar dapat mendukung ekosistem kampus hijau yang berkelanjutan.

Implementasi sistem dilakukan dengan mengintegrasikan beberapa komponen utama seperti panel surya, pengontrol pengisian (*solar charge controller*), baterai penyimpanan, inverter daya, konverter tegangan, serta unit mikrokontroler. Selain komponen daya, dipasang pula beberapa sensor instrumentasi, perangkat proteksi keamanan, dan kipas pendingin. Seluruh komponen tersebut dirancang agar dapat saling terhubung dan bekerja sebagai satu kesatuan sistem stasiun yang utuh.

Implementasi perangkat lunak dilakukan pada sisi mikrokontroler, aplikasi seluler, dan halaman web. Program pada mikrokontroler dibuat untuk mengatur proses pembacaan parameter arus, tegangan, suhu, serta mengeksekusi perintah kendali kipas dan pemutus arus. Sementara itu, aplikasi seluler dan dasbor web diimplementasikan untuk menyediakan antarmuka pengguna dalam mengelola saldo, transaksi, serta memantau kondisi operasional stasiun secara *real-time*.

Setelah seluruh proses implementasi selesai dilakukan, tahap berikutnya adalah pengujian sistem untuk memastikan seluruh fungsi dapat berjalan dengan baik. Pengujian dilakukan pada masing-masing bagian perangkat keras maupun integrasi perangkat lunak untuk mengetahui tingkat keberhasilan stasiun dalam melayani proses pengisian daya kendaraan secara aman dan akurat.

---

## 1.2. Detil Implementasi

### 1.2.1 Implementasi Perangkat Keras (Hardware)

#### 1.2.1.1 Modul Pembangkitan dan Pengisian Baterai (Solar & Charging Module)
*   **Panel Surya 100Wp 12V (4 Panel):** Dirangkai secara seri penuh atau konfigurasi *4-Series* (4S). Konfigurasi seri ini bertujuan untuk menaikkan tegangan nominal keluaran (*Open Circuit Voltage* / $V_{oc}$) panel agar berada di atas tegangan baterai (48 V) sehingga memicu interkoneksi yang efisien meskipun dalam kondisi intensitas cahaya matahari rendah. Hubungan antar panel menggunakan konektor MC4 standar luar ruangan.
    
    *(Mahasiswa memasukkan Gambar 1.2.1.1: Panel 100Wp secara manual)*
    `Gambar 1.2.1.1 Panel 100Wp`

*   **MPPT Solar Charge Controller (SCC) 48V 60A:** Bertindak sebagai regulator cerdas yang melacak titik daya maksimum (*Maximum Power Point Tracking*) dari rangkaian panel surya 4S (4 seri). Modul ini menurunkan tegangan tinggi dari panel menjadi tegangan pengisian baterai berkapasitas 48 V dengan efisiensi konversi yang tinggi.
    
    *(Mahasiswa memasukkan Gambar 1.2.1.2: SCC MPPT 60A secara manual)*
    `Gambar 1.2.1.2 SCC MPPT 60A`

*   **Aki SLA / Lead Acid 12V 12Ah (4 Aki):** Berfungsi sebagai media penyimpanan energi harian (*battery buffer*). Keempat aki dirangkai secara seri ($4 \times 12\text{ V}$) untuk membentuk satu bank baterai dengan tegangan nominal sebesar 48 V dan kapasitas 12 Ah.

#### 1.2.1.2 Modul Konversi Daya Output (Power Conversion Module)
Output daya dari bank baterai 48 V didistribusikan secara bercabang (*parallel branching*) ke dalam dua jalur pengisian daya kendaraan yang berbeda:
*   **Jalur AC (Pure Sine Wave Inverter 48V to 220V AC 1000W - NBQ1000W):** Modul ini mengonversi tegangan searah 48 V dari baterai menjadi tegangan bolak-balik 220V AC dengan gelombang sinus murni (*pure sine wave*). Jalur ini dihubungkan ke *stop kontak AC panel mount* yang ditujukan untuk mencatu perangkat pengisi daya (*charger* bawaan) sepeda motor listrik.
*   **Jalur DC (DC-DC Boost Converter 1200W 20A - Step Up Current Booster):** Mengubah tegangan input baterai 48 V naik menjadi 54.6 V DC secara konstan dengan penguat arus. Jalur keluaran DC ini disalurkan via konektor XT60/XT90 untuk melakukan pengisian daya langsung pada paket baterai sepeda listrik yang membutuhkan tegangan regulasi standar di kisaran tersebut.

#### 1.2.1.3 Modul Mikrokontroler, Instrumentasi, dan Sensor (Control & IoT Module)
*   **ESP32 DevKit V4 WROOM 38 Pin & Expansion Shield:** Bertindak sebagai unit pemroses sentral (MCU) untuk seluruh sistem instrumentasi dan komunikasi nirkabel. Pemasangan di atas *expansion shield* bertujuan untuk mempermudah distribusi pin I/O, jalur tegangan, dan *grounding* menggunakan kabel jumper dupont dan *header pin*.
*   **DC-DC Buck Converter HV 48V to 12V / 5V:** Mengingat tegangan bank baterai sangat tinggi (48 V nominal, dapat mencapai 54 V saat *full charge*), modul *buck converter step-down* khusus tegangan tinggi (HV) digunakan untuk menurunkan tegangan baterai secara aman menjadi 12 V (untuk catu daya kipas) dan 5 V (untuk mencatu ESP32 dan sensor).
*   **DS18B20 Waterproof Temperature Sensor:** Sensor suhu digital berbasis protokol *One-Wire* yang ditempelkan pada komponen penghasil panas di dalam boks untuk memantau suhu operasional internal secara *real-time*.
*   **ACS712 Current Sensor & Rangkaian Voltmeter Divider:** Sensor ACS712 mendeteksi arus pengisian daya yang mengalir ke baterai memanfaatkan efek Hall. Sementara instrumentasi pemantauan tegangan baterai dijembatani oleh sirkuit pembagi tegangan (*voltage divider*) eksternal dengan resistor pack $10\text{ }\Omega$ dan $100\text{ }\Omega$ serta komponen kapasitor filter (100nF keramik dan 220nF elektrolit) guna meredam derau (*noise*) tegangan tinggi agar dapat dibaca dengan aman oleh pin ADC ESP32 ($< 3.3\text{ V}$).
*   **Voltmeter Ammeter Digital DC:** Dipasang pada panel sebagai perangkat pemantau visual lokal (*local telemetry indicator*) bagi operator di lapangan.

#### 1.2.1.4 Modul Pengaman Sistem (Safety Module)
Untuk menjamin keamanan kelistrikan dari bahaya arus pendek (*short circuit*) dan beban berlebih (*overload*), dipasang beberapa proteksi bertingkat:
*   **DC MCB 2P 10A:** Dipasang pada jalur kutub positif dan negatif antara output rangkaian Panel Surya menuju input MPPT SCC.
*   **Fuse 20A:** Dipasang pada jalur arus tinggi dari baterai 48 V menuju Pure Sine Wave Inverter.
*   **Fuse 10A:** Dipasang pada jalur daya dari baterai menuju DC-DC Boost Converter.
*   **Fuse 3A–5A:** Memproteksi input daya rendah pada sistem *buck converter* dan relai kendali ESP32.
*   **Emergency Push Button NC & Battery Disconnect Switch 48V:** *Switch* fisik pemutus utama diletakkan di luar panel. *Emergency button* bertipe *Normally Closed* (NC) diintegrasikan langsung untuk memutus aliran pemicu pada *Relay Module 2 Channel* secara instan apabila terjadi kondisi darurat di lapangan. Seluruh sambungan kabel daya dibungkus aman menggunakan *heat shrink tube* dan isolasi listrik.

#### 1.2.1.5 Modul Mekanikal dan Sistem Pendingin (Cooling Module)
*   **Cooling Fan DC 12V 2-Wire & MOSFET IRLZ44N:** Sistem pendinginan aktif menggunakan satu unit kipas pendingin 12 V yang diletakkan pada posisi ventilasi *box panel* dan dilindungi oleh *fan grill*.
*   **Rangkaian Driver MOSFET:** Karena pin digital ESP32 tidak dapat menyuplai arus besar untuk kipas 12 V, digunakan sebuah transistor MOSFET IRLZ44N sebagai sakelar elektronik. Pin gate MOSFET dihubungkan ke pin PWM ESP32 (diproteksi dengan resistor *pulldown* $10\text{ }\Omega$ dan resistor *gate* $220\text{ }\Omega$). Sebuah dioda flyback 1N5819 / FR107 dipasang paralel terbalik pada beban kipas untuk mengeliminasi lonjakan tegangan induktif (*back-EMF*) saat kipas dimatikan. Papan PCB juga didukung oleh *baut spacer* dan komponen *heatsink* tambahan pada komponen konverter daya.

#### 1.2.1.6 Konfigurasi Arsitektur Sistem Final
Secara keseluruhan, integrasi seluruh modul di atas membentuk kesatuan arsitektur sistem pengisian daya terdistribusi seperti yang digambarkan pada diagram blok operasional berikut:

```
[Rangkaian Panel Surya 4S (400Wp)]
               │
          (DC MCB 10A)
               ▼
[MPPT SCC 48V 30A] ───► [Aki SLA 48V (4x12V Seri)]
               │
 ┌─────────────┼─────────────┐
 ▼             ▼             ▼
(Fuse 20A)  (Fuse 10A)  (Fuse 3A-5A)
 │             │             │
[Inverter]  [Boost]     [Buck Converter]
[PSW 220V]  [Conv 54.6V]   [48V-12V/5V]
 │             │             │
 ▼             ▼             ▼
(Stop AC)   (XT60/90)   [ESP32 DevKit V4]
```

ESP32 secara konstan menjalankan kode program (*firmware*) untuk melakukan dua fungsi utama, yaitu fungsi pemantauan (*monitoring*) dan fungsi eksekusi kendali (*controlling*):
1.  **Fungsi Pemantauan:** ESP32 membaca sensor suhu DS18B20 secara digital, serta mengukur tegangan bank baterai dan arus *charging* kelistrikan melalui pin ADC yang telah terfilter oleh kombinasi kapasitor ($1000\mu\text{F 63 V}$ pada bus utama, serta $470\mu\text{F}$ pada jalur rendah). Data instrumentasi ini dikemas dalam protokol data ringan dan dikirimkan secara nirkabel menuju Dashboard Web Admin SunVolt.
2.  **Fungsi Eksekusi Kendali:** Berdasarkan instruksi manual yang dikirimkan oleh administrator melalui halaman web *maintenance*, ESP32 dapat mengatur kecepatan putaran kipas secara manual melalui modulasi lebar pulsa (*Control PWM Fan*). Selain itu, perintah penghentian darurat (*Emergency Cutoff*) yang diinput via web maupun penekanan *Emergency Switch* fisik secara instan akan memicu *Relay Module 2 Channel* untuk memutus aliran daya utama ke arah beban kendaraan.

#### 1.2.1.7 Rangka Charging Station
Rancang bangun mekanikal dari stasiun pengisian daya (*charging station*) ini didesain menggunakan pendekatan struktur mandiri (*standalone shelter*) bertingkat yang kokoh, ringkas, dan ergonomis. Berdasarkan hasil pabrikasi fisik purwarupa, material utama rangka menggunakan profil besi kotak (*hollow steel*) yang disambung menggunakan teknik pengelasan busur listrik murni demi menjamin rigiditas kompartemen terhadap beban statis komponen daya.

Sebagai lapisan pengondisi struktural dan tempat peletakan komponen, sasis besi ini dikombinasikan dengan lembaran panel ACP (*Aluminium Composite Panel*). Secara fungsional dan struktural, konstruksi rangka charging station ini dibagi menjadi 3 (tiga) segmen utama:
1.  **Rangka Atas (Penyangga Panel Surya / Top Stage):** Segmen rangka bagian atas dirancang khusus sebagai struktur kanopi miring ganda (*double-pitched canopy skeleton*) yang berfungsi sebagai dudukan (*mounting frame*) utama bagi 4 unit panel surya 100Wp. Di antara panel surya dan struktur rangka besi kotak, dipasang lembaran panel ACP sebagai lapisan perantara (*sandwich layer*). Pemasangan ACP di area ini berfungsi untuk mendistribusikan beban mekanis panel surya secara merata, meredam getaran, serta bertindak sebagai atap pelindung lapis pertama yang mencegah kebocoran air hujan langsung mengenai sela-sela kabel di bawahnya. Selain itu, sifat isolatif dari ACP membantu meminimalkan transfer panas berlebih dari panel surya ke sasis besi utama. Sudut kemiringan rangka atas dikonstruksi secara presisi untuk mengoptimalkan tangkapan iradiasi matahari sekaligus mempermudah jatuhnya air hujan secara alami.
    
    *(Mahasiswa memasukkan Gambar 1.2.1.3: Rangka Atas Penopang Panel Surya secara manual)*
    `Gambar 1.2.1.3 Rangka Atas Penopang Panel Surya`

2.  **Rangka Tengah (Kompetemen Elektronika dan Daya / Middle Stage):** Segmen rangka bagian tengah bertindak sebagai pusat fungsional atau inti penempatan modul operasional sistem pengisian daya. Rangka ini menyediakan platform horizontal dan vertikal bertingkat yang dioptimalkan dengan material modular. Di dalam rangka tengah, panel ACP dipasang secara vertikal/horizontal sebagai papan dudukan (*mounting plate*) utama untuk menempatkan blok komponen cerdas, seperti MPPT Solar Charge Controller (SCC), sirkuit elektronika kendali (ESP32 expansion board), sensor-sensor, dan modul relai.
    
    Penggunaan ACP sebagai *mounting board* sangat krusial karena material aluminium-komposit ini bersifat non-konduktif pada permukaannya, sehingga mencegah terjadinya korsleting akibat kontak langsung antara PCB/pin komponen dengan rangka besi kotak. Selain itu, ACP mempermudah proses tata letak (*layouting*) komponen karena strukturnya yang mudah dibor untuk pemasangan baut spacer dan skrup. Rangka tengah ini juga menahan beban dari bank baterai aki SLA 48V (4 unit aki seri) serta inverter sinus murni. Ketinggian rangka tengah disesuaikan dengan standar antropometri manusia agar mempermudah operator saat melakukan pemeliharaan teknis (*maintenance access*), serta memisahkan area kabel arus lemah (sensor) dan arus kuat (daya) untuk menghindari interferensi sinyal.
    
    *(Mahasiswa memasukkan Gambar 1.2.1.4: Rangka Tengah - Penopang Komponen secara manual)*
    `Gambar 1.2.1.4 Rangka Tengah - Penopang Komponen`

    *(Mahasiswa memasukkan Gambar 1.2.1.5: Rangka Tengah - Ruang Untuk Baterai secara manual)*
    `Gambar 1.2.1.5 Rangka Tengah - Ruang Untuk Baterai`

3.  **Rangka Bawah (Penopang Utama dan Kaki-Kaki / Bottom Stage):** Segmen rangka bagian bawah merupakan pondasi atau kaki-kaki penopang (*support base legs*) dari keseluruhan struktur charging station. Rangka bawah ini memiliki dimensi penampang yang lebih melebar untuk memindahkan titik berat (*center of gravity*) stasiun serendah mungkin ke permukaan tanah. Berfungsi mendistribusikan beban statis total dari rangka atas dan tengah secara merata ke permukaan lantai parkir guna mencegah risiko struktur terguling akibat terpaan angin luar ruangan (*outdoor wind load protection*). Pada prototipe ini, rangka bawah dirancang melebar ke dua sisi samping membentuk struktur dudukan horizontal bawah (*lower metal shelf*), yang selain meningkatkan kestabilan sasis, juga dipersiapkan sebagai landasan mekanikal penempatan kabinet luar (*enclosure box protect*) pelindung komponen-komponen kritis.

### 4.2.2 Implementasi Perangkat Lunak Aplikasi
Implementasi perangkat lunak aplikasi SunVolt dilakukan untuk merealisasikan antarmuka pengguna berbasis aplikasi seluler (*mobile application*) dan layanan *backend server* yang menghubungkan pengguna akhir (*end-user*), stasiun pengisian daya fisik, serta sistem pembayaran digital non-tunai. Secara arsitektur, aplikasi dibangun menggunakan *framework* **Flutter (Dart)** pada sisi *frontend* dan **Node.js (Express.js)** yang di-deploy pada platform *serverless Vercel* pada sisi *backend*, serta terintegrasi dengan basis data awan **Firebase Firestore**. Seluruh kode sumber dikelola secara modular pada direktori proyek `SunVolt/` dan disimpan dalam repositori Git publik (`https://github.com/SAF134/SunVolt`).

Rincian implementasi modul-modul perangkat lunak aplikasi dijelaskan pada subbab berikut:

#### 4.2.2.1 Modul Halaman Login
Modul halaman login (`welcome_screen.dart` dan `auth_service.dart`) bertindak sebagai gerbang utama autentikasi identitas pengguna dengan mengintegrasikan layanan *Firebase Authentication* dan *Google Sign-In (OAuth 2.0)*. Saat pengguna melakukan *sign-in* menggunakan akun Google, *AuthService* memverifikasi *OAuth ID Token* untuk menerbitkan UID unik, serta secara otomatis menginisialisasi dokumen profil pengguna baru di Cloud Firestore pada path `users/{uid}` dengan saldo default Rp 0 jika akun baru terdaftar, sebelum mengarahkan navigasi pengguna menuju Halaman Peta Utama.

*(Mahasiswa memasukkan Gambar 1.2.2.1: Halaman Login secara manual)*
`Gambar 1.2.2.1 Halaman Login`

#### 4.2.2.2 Modul Halaman Peta Utama
Modul halaman peta utama (`home_screen.dart`) menyajikan pemetaan geografis interaktif berbasis *Flutter Map* dan ubin *OpenStreetMap* untuk menampilkan lokasi stasiun pengisian daya SunVolt beserta koordinat lokasi GPS pengguna secara *real-time*. Modul ini terhubung dengan *Open Source Routing Machine* (OSRM) REST API untuk menghitung rute rill jalan berkendara (*driving route*) dan deskripsi jarak tempuh, yang dilengkapi sirkuit pencadangan otomatis (*fallback*) berbasis *Haversine formula* dikalikan faktor kelokan jalan sebesar 1,3 guna menjamin keandalan estimasi jarak meskipun terjadi gangguan jaringan internet.

*(Mahasiswa memasukkan Gambar 1.2.2.2: Halaman Beranda secara manual)*
`Gambar 1.2.2.2 Halaman Beranda`

#### 4.2.2.3 Modul Detail Stasiun
Modul detail stasiun (`station_detail_screen.dart`) berfungsi sebagai pusat konfirmasi operasional dan validasi kelayakan saldo sebelum sesi pengisian daya dimulai. Selain menampilkan status ketersediaan port, spesifikasi daya, dan pilihan tipe kendaraan (Sepeda Listrik DC 54.6V / Motor Listrik AC 220V), modul ini memeriksa batas saldo dompet pengguna di Cloud Firestore (minimal Rp 10.000). Jika saldo pengguna di bawah batas minimum, aplikasi akan memblokir pengisian dan menampilkan pesan peringatan visual (*SnackBar*), sedangkan jika saldo mencukupi, modul memicu dialog konfirmasi interaktif (*SunVoltConfirmationDialog*) untuk memulai sesi pengisian.

*(Mahasiswa memasukkan Gambar 1.2.2.3: Halaman Detail Stasiun secara manual)*
`Gambar 1.2.2.3 Halaman Detail Stasiun`

#### 4.2.2.4 Modul Sesi Pengisian Daya
Modul sesi pengisian daya (`charging_status_screen.dart`) mengelola pemantauan telemetri kelistrikan dan pemrosesan transaksi pengisian daya secara *real-time* berbasis komponen *StreamBuilder* yang terhubung ke Firestore Sekunder (`sunvolt-admin`). Modul mendengarkan perubahan data arus ($A$) dan daya ($W$) dari mikrokontroler ESP32 di lapangan dengan latensi rata-rata 0,473 detik, me-render grafik daya bergerak, mengalkulasi akumulasi energi ($kWh$) dan tarif berjalan ($Rp$), serta mengeksekusi pemotongan saldo dompet secara atomik (`FieldValue.increment` negatif) di Firestore Utama saat pengisian selesai.

*(Mahasiswa memasukkan Gambar 1.2.2.4: Halaman Pengisian Daya secara manual)*
`Gambar 1.2.2.4 Halaman Pengisian Daya`

#### 4.2.2.5 Modul Dompet Digital
Modul dompet digital (`wallet_screen.dart`) bertindak sebagai pusat pengelolaan finansial non-tunai (*e-wallet*) yang menyajikan sisa saldo pengguna secara *real-time* dari Cloud Firestore beserta pilihan nominal cepat pengisian ulang (*top-up*) mulai dari Rp 15.000 hingga Rp 100.000. Modul ini dilengkapi mekanisme *balance snapshot listener* yang secara aktif mendeteksi penambahan saldo masuk pasca-pembayaran dan secara otomatis mengarahkan navigasi pengguna ke layar konfirmasi sukses pembayaran (`PaymentSuccessScreen`) tanpa memerlukan pembaruan halaman manual.

*(Mahasiswa memasukkan Gambar 1.2.2.5: Halaman Dompet secara manual)*
`Gambar 1.2.2.5 Halaman Dompet`

#### 4.2.2.6 Modul Riwayat Aktivitas
Modul riwayat aktivitas (`history_screen.dart`) menyajikan catatan log histori transaksi dan penggunaan stasiun pengisian daya secara reaktif dengan berlangganan pada sub-koleksi `activity_history` di Firestore Utama. Untuk mengoptimalkan kinerja memori (*RAM usage*) perangkat saat memuat data dalam jumlah besar, modul menerapkan teknik paginasi *lazy loading* (8 dokumen per halaman) serta menampilkan visualisasi animasi *shimmer skeleton loading* (`sunvolt_shimmer.dart`) saat data sedang diunduh dari Cloud Database.

*(Mahasiswa memasukkan Gambar 1.2.2.6: Halaman Riwayat Aktivitas secara manual)*
`Gambar 1.2.2.6 Halaman Riwayat Aktivitas`

#### 4.2.2.7 Modul Pembayaran
Modul pembayaran (`qris_payment_screen.dart`) memfasilitasi transaksi pengisian ulang saldo dompet secara digital melalui standar pembayaran nasional QRIS (*Quick Response Code Indonesian Standard*). Modul menyusun payload data transaksi, mengirimkan permintaan HTTP POST ke server *backend API* untuk meminta penerbitan *Snap Token Midtrans*, dan meluncurkan peramban web/webview eksternal via pustaka `url_launcher` guna menampilkan kode QRIS Midtrans Sandbox yang dapat dipindai langsung oleh pengguna.

*(Mahasiswa memasukkan Gambar 1.2.2.7: Halaman Pembayaran QRIS secara manual)*
`Gambar 1.2.2.7 Halaman Pembayaran QRIS`

#### 4.2.2.8 Modul Server Backend
Modul server backend (`index.js`) dibangun menggunakan *framework* Node.js dan Express.js serta di-deploy pada platform *Vercel Serverless* untuk bertindak sebagai *middleware API* terisolasi yang mengamankan *Server Key* Midtrans. Server menyediakan dua titik akhir API utama, yaitu `/api/create-transaction` untuk menerbitkan *Snap Redirect URL* dan `/api/midtrans-callback` untuk memverifikasi keaslian notifikasi *webhook* pembayaran berbasis hash *SHA-512 Signature Key*, serta memicu penambahan saldo dompet pengguna di Cloud Firestore secara atomik (`FieldValue.increment`). Modul ini juga mengelola skema struktur basis data terpusat pada Firebase Firestore yang dipetakan pada Tabel 1.2.1 (Koleksi `users`), Tabel 1.2.2 (Sub-koleksi `activity_history`), dan Tabel 1.2.3 (Koleksi `transactions`).

*(Mahasiswa memasukkan Gambar 1.2.2.8: Halaman Dashboard Sandbox Midtrans secara manual)*
`Gambar 1.2.2.8 Halaman Dashboard Sandbox Midtrans`

*(Mahasiswa memasukkan Gambar 1.2.2.9: Halaman Pembayaran Sandbox Midtrans secara manual)*
`Gambar 1.2.2.9 Halaman Pembayaran Sandbox Midtrans`

*(Mahasiswa memasukkan Gambar 1.2.2.10: Halaman Notifikasi Pembayaran secara manual)*
`Gambar 1.2.2.10 Halaman Notifikasi Pembayaran`

*(Mahasiswa memasukkan Gambar 1.2.2.11: Halaman Server Backend Vercel secara manual)*
`Gambar 1.2.2.11 Halaman Server Backend Vercel`

**Tabel 1.2.1 Tabel Koleksi User**

| Field | Tipe | Keterangan |
| :--- | :--- | :--- |
| email | string | Alamat email terdaftar pengguna |
| name | string | Nama lengkap pengguna |
| balance | number | Nominal saldo dompet digital (Rupiah) |
| createdAt | timestamp | Tanggal pertama kali akun dibuat |

**Tabel 1.2.2 Tabel Sub Koleksi/Riwayat Aktivitas**

| Field | Tipe | Keterangan |
| :--- | :--- | :--- |
| title | string | Judul aktivitas ("Top-Up Dompet" / "Pengisian Daya") |
| subtitle | string | Subjudul transaksi ("QRIS" / "Stasiun SunVolt") |
| amount | string | Nominal perubahan saldo (Format "+Rp" / "-Rp") |
| energy | string | Akumulasi pemakaian daya ("0.82 kWh") |
| type | string | Label pengenal tipe ("topup" / "charging") |
| isPositive | boolean | Nilai true untuk penambahan, false untuk pengurangan |
| timestamp | timestamp | Waktu transaksi kelipatan waktu server |

**Tabel 1.2.3 Tabel Koleksi Transactions**

| Field | Tipe | Keterangan |
| :--- | :--- | :--- |
| orderId | string | ID transaksi unik pesanan Midtrans |
| userId | string | UID instansi pengguna dari Firebase Auth |
| amount | number | Nilai nominal uang top-up |
| customerEmail| string | E-mail akun pelanggan |
| status | string | Status invoice ("pending" / "settlement") |
| createdAt | timestamp | Tanggal dibuatnya invoice pembayaran |

*(Mahasiswa memasukkan Gambar 1.2.2.12: Halaman Dashboard Firebase secara manual)*
`Gambar 1.2.2.12 Halaman Dashboard Firebase`

---

### 1.2.3 Implementasi Perangkat Lunak (Software) Website Admin Monitoring SunVolt Hub
Luaran utama sub-sistem ini adalah *source code* aplikasi web berbasis browser yang dibangun menggunakan framework React (Vite) dengan bahasa JavaScript. Berbeda dengan aplikasi mobile SunVolt yang ditujukan kepada pengguna umum, web admin monitoring ini bersifat internal dan hanya dapat diakses oleh anggota tim pengembang yang terdaftar. Web ini terhubung ke proyek Firebase tersendiri (`sunvolt-admin`) yang terpisah dari Firebase milik aplikasi mobile, sehingga data hardware stasiun pengisian tidak bercampur dengan data transaksi pengguna. Proses *deployment* dilakukan secara semi-otomatis melalui alur VSCode $\rightarrow$ GitHub $\rightarrow$ Vercel, di mana setiap *push* ke *branch* utama secara otomatis memperbarui versi publik yang di-host oleh Vercel.

Paparan berikut menyajikan seluruh *source code* utama yang dikerjakan oleh tim *capstone*, disusun per modul dan disertai penjelasan kegunaan instruksi, variabel, dan fungsi di dalamnya.

*   **Repository Website Admin:** https://github.com/FireCalm2/sunvolt-admin/

#### 1.2.3.1 Struktur Proyek
Sebelum membahas detail *source code*, berikut adalah struktur direktori proyek web admin monitoring SunVolt Hub:

```
SunVolt-Admin-Web/
├── public/
│    └── Logo_SunVolt.png               ← Aset logo halaman login
├── src/
│    ├── main.jsx                       ← Titik masuk web & auth state
│    ├── App.jsx                        ← Komponen dashboard utama
│    ├── login.jsx                      ← Halaman login & whitelist guard
│    ├── firebase.js                    ← Inisialisasi Firebase web
│    └── index.css                      ← Konfigurasi Tailwind CSS
├── index.html                          ← Entry shell HTML tunggal (SPA)
├── vite.config.js                      ← Konfigurasi bundler Vite
└── package.json                        ← Dependensi proyek web
```
Web ini merupakan *Single Page Application* (SPA), artinya seluruh navigasi antar tampilan (login $\rightarrow$ dashboard $\rightarrow$ tab) terjadi di sisi browser tanpa perpindahan halaman. Komponen `main.jsx` bertindak sebagai *root* yang memutuskan apakah me-*render* halaman login atau dashboard berdasarkan status autentikasi Firebase secara *real-time*.

#### 1.2.3.2 Konfigurasi Firebase
File ini bertugas menginisialisasi koneksi ke proyek Firebase `sunvolt-admin` dan mengekspor *instance* layanan yang dibutuhkan oleh modul-modul lainnya.

```javascript
// firebase.js
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";
import { getAuth, GoogleAuthProvider } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyApn4txSJN29ZRle9hOqMli0zfkya8Uh-Q",
  authDomain: "sunvolt-admin.firebaseapp.com",
  projectId: "sunvolt-admin",
  storageBucket: "sunvolt-admin.firebasestorage.app",
  messagingSenderId: "759944928251",
  appId: "1:759944928251:web:602607c4d46d04bf86c95e",
  measurementId: "G-Y6X03PP9EV"
};

const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
export const db = getFirestore(app);
export const auth = getAuth(app);
export const googleProvider = new GoogleAuthProvider();
```
*   **Penjelasan Fungsi:**
    *   `firebaseConfig`: Objek konfigurasi berisi kredensial proyek Firebase admin. Bersifat client-side aman karena akses database dikendalikan oleh *Firebase Security Rules*.
    *   `initializeApp(firebaseConfig)`: Fungsi utama menginisialisasi koneksi ke proyek Firebase.
    *   `db`: Ekspor *instance* database Firestore yang digunakan oleh modul `App.jsx` untuk mendengarkan perubahan parameter stasiun secara live.

#### 1.2.3.3 Modul Titik Masuk Web
File `main.jsx` merupakan titik masuk (*entry point*) seluruh aplikasi web. Di sinilah React di-*mount* ke DOM, dan di sinilah *observer* status autentikasi dipasang untuk mengontrol tampilan yang di-render.

```javascript
// main.jsx
import { StrictMode, useState, useEffect } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import { auth } from './firebase'
import { onAuthStateChanged } from 'firebase/auth'
import App from './App.jsx'
import Login from './login.jsx'

function Root() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (firebaseUser) => {
      setUser(firebaseUser);
      setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  if (loading) {
    return <div className="min-h-screen bg-[#0f1115]"></div>;
  }
  
  return user ? <App user={user} /> : <Login setUser={setUser} />;
}

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <Root />
  </StrictMode>,
)
```
*   **Penjelasan Variabel & State:**
    *   `Root()`: Komponen tertinggi yang memutuskan tampilan halaman utama berdasarkan status login user.
    *   `onAuthStateChanged()`: *Observer* Firebase Auth yang langsung terpanggil setiap kali status login berubah (masuk, keluar, atau segarkan halaman).
    *   `unsubscribe()`: Fungsi pembersih (*cleanup*) untuk melepas pengawasan ketika komponen dilepas dari DOM untuk mencegah *memory leak*.

#### 1.2.3.4 Modul Autentikasi & Kontrol Akses
File `login.jsx` menangani tampilan halaman login sekaligus lapisan keamanan (*whitelist guard*) yang memastikan hanya email terdaftar yang dapat masuk ke dashboard.

```javascript
// login.jsx
import { useState } from 'react';
import { signInWithPopup, signOut } from "firebase/auth";
import { auth, googleProvider } from "./firebase";

const ALLOWED_EMAILS = [
  "firecalm2@gmail.com",
  "syauqiakmal137@gmail.com",
  "fattaha.rasyad@gmail.com"
];

function Login({ setUser }) {
  const [loginError, setLoginError] = useState("");

  const handleLogin = async () => {
    try {
      setLoginError("");
      const result = await signInWithPopup(auth, googleProvider);
      const email = result.user.email;
      
      if (ALLOWED_EMAILS.includes(email)) {
        setUser(result.user);
      } else {
        await signOut(auth);
        setLoginError(`Akses Ditolak: ${email} tidak terdaftar di sistem.`);
      }
    } catch (error) {
      console.error("Login error:", error);
    }
  };
}
```
*   **Penjelasan Logika & Variabel:**
    *   `ALLOWED_EMAILS`: Array berisi daftar email tim pengembang yang diizinkan masuk. Email di luar whitelist ini akan diputus sesinya otomatis menggunakan perintah `signOut(auth)`.
    *   `signInWithPopup(auth, googleProvider)`: Membuka jendela popup otorisasi Google Auth di browser client.

```javascript
// Tampilan Login UI HTML
return (
  <div className="min-h-screen bg-[#0f1115] flex flex-col items-center justify-center p-4 font-sans">
    <div className="bg-[#1a1d24] p-8 rounded-3xl border border-slate-800/80 text-center max-w-sm w-full">
      <div className="mb-8 flex flex-col items-center">
        <img src="/Logo_SunVolt.png" alt="SunVolt Logo" className="w-10 h-10 object-contain drop-shadow-md" />
        <h1 className="text-4xl font-black tracking-wide">
          <span className="text-emerald-500">SUN</span>
          <span className="text-yellow-400">VOLT</span>
        </h1>
        <p className="text-slate-400 text-xs tracking-widest uppercase font-semibold mt-2">Secure Admin Access</p>
      </div>
      <button onClick={handleLogin} className="w-full bg-white text-slate-900 font-bold py-3 px-4 rounded-xl flex items-center justify-center gap-2 hover:bg-slate-200">
        Continue with Google
      </button>
      {loginError && (
        <div className="mt-6 p-3 bg-red-500/10 border border-red-500/30 rounded-lg text-red-400 text-xs text-left">
          <span className="font-bold">Security Alert:</span><br/> {loginError}
        </div>
      )}
    </div>
  </div>
);
```

#### 1.2.3.5 Modul Dashboard Utama
File `App.jsx` merupakan komponen terbesar yang menampung seluruh logika pemantauan *hardware* dan semua tab tampilan dashboard. Modul ini dibagi menjadi empat bagian utama: inisialisasi state, real-time listener, logika tab, dan fungsi ekspor data.

##### Bagian 1 — Inisialisasi State & Real-time Listener
```javascript
// App.jsx (State dan Snapshots)
import { useState, useEffect } from 'react';
import { doc, onSnapshot } from "firebase/firestore";
import { signOut } from "firebase/auth";
import { db, auth } from "./firebase";

function App({ user }) {
  const [logs, setLogs] = useState([]);
  const [history, setHistory] = useState({ voltage: [], current: [], battery: [], timestamps: [] });
  const [activeTab, setActiveTab] = useState('Overview');
  const [data, setData] = useState({
    batteryLevel: 0,
    pvVoltage: 0,
    pvCurrent: 0,
    status: "Connecting...",
    user: "student@telkom.edu",
    bmsTemp: 34,
    boostTemp: 45
  });

  useEffect(() => {
    if (!user) return;
    const unsub = onSnapshot(doc(db, "stations", "station_01"), (docSnap) => {
      if (docSnap.exists()) {
        const newData = docSnap.data();
        setData((prev) => {
          if (newData.status && prev.status !== newData.status) {
            const timestamp = new Date().toLocaleTimeString();
            setLogs(prevLogs => [
              `[${timestamp}] Status: ${newData.status}`,
              ...prevLogs
            ].slice(0, 50));
          }
          return { ...prev, ...newData };
        });
        
        // Perekaman data grafik
        if (newData.pvVoltage !== undefined) {
          setHistory(prev => ({
            voltage: [...prev.voltage, newData.pvVoltage].slice(-24),
            current: [...prev.current, newData.pvCurrent].slice(-24),
            battery: [...prev.battery, newData.batteryLevel].slice(-24),
            timestamps: [...prev.timestamps, new Date().toLocaleTimeString()].slice(-24)
          }));
        }
      }
    });
    return () => unsub();
  }, [user]);
}
```
*   **Penjelasan Fungsi:**
    *   `onSnapshot()`: Memasang fungsi pendengar data permanen ke Firestore. Setiap kali stasiun pengisian mengirim data telemetri baru, callback ini langsung mengeksekusi pembaruan visual web admin tanpa perlu melakukan penyegaran manual (*refresh page*).
    *   `history`: State array untuk menampung 24 koordinat titik telemetri kelistrikan terakhir yang akan digambarkan dalam modul grafik.

##### Bagian 2 — Tab Overview
```javascript
// App.jsx (Visualisasi Baterai CSS fill animation)
return (
  // Tab Overview
  activeTab === 'Overview' && (
    <div className="h-full flex flex-col md:flex-row items-center justify-center gap-8 md:gap-16">
      {/* Animasi Baterai */}
      <div className="w-48 h-56 rounded-2xl border-4 border-slate-700 relative overflow-hidden bg-slate-800/50 flex items-end shrink-0">
        <div className="w-full bg-emerald-400 transition-all duration-1000 ease-out absolute bottom-0" style={{ height: `${data.batteryLevel}%` }} />
        <div className="absolute inset-0 flex items-center justify-center z-10">
          <span className="text-4xl font-black text-white">{data.batteryLevel}%</span>
        </div>
      </div>
      
      {/* Sesi Aktif */}
      <div className="bg-[#1a1d24] p-6 rounded-xl border border-slate-700/50 w-full md:w-auto flex-1">
        <div className="text-xs text-slate-400 mb-4 uppercase tracking-wider font-semibold">Active Session</div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div>
            <div className="text-[10px] text-slate-500 uppercase">Port Status</div>
            <div className="text-emerald-400 font-bold text-lg">{data.status}</div>
          </div>
          <div>
            <div className="text-[10px] text-slate-500 uppercase">Current Flow</div>
            <div className="text-white font-bold text-lg">{data.pvCurrent} A</div>
          </div>
          <div>
            <div className="text-[10px] text-slate-500 uppercase">User ID</div>
            <div className="text-white font-bold text-sm truncate">{data.user}</div>
          </div>
        </div>
      </div>
    </div>
  )
);
```

##### Bagian 3 — Tab Diagnostics & Live Chart
```javascript
// App.jsx (Metrik Diagnostik)
activeTab === 'Diagnostics' && (
  <div className="grid grid-cols-2 md:grid-cols-4 gap-4 h-full content-start text-left">
    <div className="bg-[#1a1d24] p-4 rounded-xl border border-slate-700/50">
      <div className="text-xs text-slate-400 mb-3 uppercase tracking-wider font-semibold">Solar</div>
      <div className="text-[10px] text-slate-500">Voltage: {data.pvVoltage} V</div>
      <div className="text-[10px] text-slate-500">Current: {data.pvCurrent} A</div>
    </div>
    
    <div className="bg-[#1a1d24] p-4 rounded-xl border border-slate-700/50">
      <div className="text-xs text-slate-400 mb-3 uppercase tracking-wider font-semibold">BMS</div>
      <div className="text-[10px] text-slate-500">Temp</div>
      <div className={`font-bold ${data.bmsTemp >= 50 ? 'text-red-500 animate-pulse' : 'text-white'}`}>{data.bmsTemp} °C</div>
    </div>
    
    <div className="bg-[#1a1d24] p-4 rounded-xl border border-slate-700/50">
      <div className="text-xs text-slate-400 mb-3 uppercase tracking-wider font-semibold">Booster</div>
      <div className="text-[10px] text-slate-500">Heatsink</div>
      <div className={`font-bold ${data.boostTemp >= 65 ? 'text-red-500 animate-pulse' : 'text-white'}`}>{data.boostTemp} °C</div>
    </div>
  </div>
);
```
*   **Penjelasan Kondisional UI:**
    *   Jika suhu BMS terdeteksi melebihi 50°C atau suhu booster di atas 65°C, kelas visual CSS secara otomatis menyematkan animasi `animate-pulse` berwarna merah sebagai tanda darurat peringatan untuk administrator.

##### Bagian 4 — Tab Logs & Ekspor Excel
```javascript
// App.jsx (Ekspor Data ke File .xlsx ExcelJS)
const exportToExcel = async () => {
  const ExcelJS = require('exceljs');
  const workbook = new ExcelJS.Workbook();
  const sheet = workbook.addWorksheet('SunVolt Data');
  
  sheet.columns = [
    { header: 'Timestamp', key: 'time', width: 15 },
    { header: 'Voltage (V)', key: 'voltage', width: 15 },
    { header: 'Current (A)', key: 'current', width: 15 },
    { header: 'Battery (%)', key: 'battery', width: 15 }
  ];
  
  sheet.getRow(1).font = { bold: true };
  history.timestamps.forEach((time, index) => {
    sheet.addRow({
      time: time,
      voltage: history.voltage[index],
      current: history.current[index],
      battery: history.battery[index]
    });
  });
  
  const buffer = await workbook.xlsx.writeBuffer();
  const blob = new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `SunVolt_Full_Log_${new Date().toLocaleDateString().replace(/\//g, '-')}.xlsx`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};
```
*   **Penjelasan Fungsi:**
    *   `exportToExcel()`: Memanfaatkan pustaka `exceljs` di sisi client untuk membuat workbook virtual, memetakan data array telemetri historis, merubahnya menjadi objek biner blob, serta memicu proses unduhan secara otomatis di browser tanpa membebani server backend.

#### 1.2.3.6 Tampilan Database Firebase Firestore
Basis data untuk web admin dikelola secara independen di dalam proyek Firebase `sunvolt-admin`. Tabel-tabel di bawah ini memetakan struktur dokumen basis datanya:

**Tabel 1.2.4 Tabel Koleksi Stations**

| Field | Tipe | Contoh Nilai | Keterangan |
| :--- | :--- | :---: | :--- |
| batteryLevel | Number | 75 | Kapasitas daya baterai cadangan stasiun (%) |
| pvCurrent | Number | 0 | Arus yang dihasilkan panel surya (Ampere) |
| pvVoltage | Number | 1.6 | Tegangan yang dihasilkan panel surya (Volt) |
| status | String | "IDLE" | Status operasional ("IDLE", "CHARGING", "ERROR") |
| timestamp | String | "23:00" | Catatan waktu pembaruan telemetri |

*(Mahasiswa memasukkan Gambar 1.2.2.13: Halaman Dashboard Admin Firebase secara manual)*
`Gambar 1.2.2.13 Halaman Dashboard Admin Firebase`

Struktur dokumen `station_01` dirancang tunggal agar pembacaan listener `onSnapshot()` dapat bekerja dengan performa tinggi pada jalur lalu lintas data telemetri seminimal mungkin.

#### 1.2.3.7 Tampilan Antarmuka Web Admin Monitoring
*   **Halaman Login Web:** Kartu antarmuka minimalis di tengah layar berlatar gelap yang menyajikan verifikasi email *whitelist* Google Sign-in untuk melarang akses luar tim.
*   **Dashboard Tab Overview:** Menampilkan widget balok tinggi baterai stasiun beserta data monitor arus dan e-mail UID pengguna yang sedang memotong saldo.
*   **Dashboard Tab Diagnostics:** Menyajikan grafik tren tegangan solar panel (menggunakan pustaka grafik `ApexCharts`) berukuran minimal 800 piksel dengan sumbu X representasi cap waktu data.
*   **Dashboard Tab Logs:** Menampilkan log baris peristiwa penting sistem dalam format terminal monospace gelap. Menampilkan tombol ekspor data spreadsheet.

---

## 1.3. Prosedur Pengoperasian

### 1.3.1 Prosedur Pengoperasian Perangkat Keras (Hardware)

#### 1.3.1.1 Tahap Inisialisasi dan Aktivasi Sistem Utama (Power-Up Sequence)
1.  **Verifikasi Tombol Darurat:** Pastikan tombol *Emergency Push Button* fisik di sisi box luar berada dalam kondisi dilepas (Normally Closed).
2.  **Pemutusan Utama Baterai:** Putar sakelar *Battery Disconnect Switch 48V* ke posisi **ON** untuk menghubungkan bank aki seri ke terminal hub kelistrikan.
3.  **Booting Mikrokontroler:** Tegangan 48V akan secara otomatis diturunkan ke 5V oleh *DC-DC Buck Converter*. Indikator LED merah pada mikrokontroler ESP32-U WROOM akan menyala konstan menandakan sistem IoT aktif.
4.  **Verifikasi Voltmeter:** Perhatikan layar *Voltmeter Ammeter Digital DC* di luar boks. Tegangan harus terbaca stabil pada rentang nominal 48V hingga 54V DC.
5.  **Aktivasi Jalur Panel Surya:** Naikkan tuas MCB DC 2P 10A untuk menghubungkan sirkuit panel surya ke SCC. SCC akan menyala dan mulai mengalirkan suplai pengisian daya ke aki.

#### 1.3.1.2 Tahap Koneksi dan Persiapan Media Pengisian (Vehicle Connection)
*   **Skenario Port AC (Motor Listrik):**
    1.  Nyalakan inverter *Pure Sine Wave* 1000W menggunakan sakelar fisik di dalam box panel.
    2.  Verifikasi lampu LED inverter menyala hijau stabil.
    3.  Hubungkan nozzle pengisi daya adaptor motor listrik ke dalam terminal colokan AC stasiun.
*   **Skenario Port DC (Sepeda Listrik):**
    1.  Ambil kabel output DC (ujung konektor XT60 / XT90) dari kompartemen stasiun.
    2.  Hubungkan konektor ke port baterai sepeda listrik secara pas (*fit*). DC-DC Boost Converter akan menyesuaikan tegangan ke batas stabil 54.6 V DC.

#### 1.3.1.3 Tahap Verifikasi Kesiapan Operasional (System Ready Verification)
1.  **Pengecekan Jaringan:** Pastikan ESP32 telah tersambung ke jaringan Wi-Fi dan berhasil membuka komunikasi nirkabel.
2.  **Validasi Sensor Live:** Melalui dasbor administrator, pastikan sensor suhu DS18B20 mendeteksi suhu di bawah 38°C dan tegangan baterai selaras dengan hasil pengukuran multimeter fisik.
3.  **Uji Kipas Pendingin:** Jalankan tombol putar kontrol PWM kipas di dasbor web admin dari 0% ke 100% untuk memverifikasi kipas berputar lancar.
4.  **Optimal Status:** Jika seluruh visualisasi dasbor menunjukkan status **"Optimal/Standby"**, stasiun pengisian siap melayani pengguna.

### 1.3.2 Prosedur Pengoperasian Perangkat Lunak Aplikasi

#### 1.3.2.1 Tahap Membuat Akun
Tahap ini menjelaskan prosedur pendaftaran akun baru bagi pengguna baru maupun masuk bagi pengguna terdaftar pada aplikasi mobile SunVolt:
1.  **Mengunduh dan Membuka Aplikasi:** Pastikan perangkat Anda menggunakan sistem operasi minimal Android 6.0 atau iOS 12.0 dan telah terpasang aplikasi SunVolt. Ketuk ikon aplikasi **SunVolt** pada menu utama ponsel Anda.
2.  **Halaman Sambutan (Splash Screen):** Aplikasi akan memuat halaman *Splash Screen* berlatar belakang gelap dengan logo SunVolt berputar selama 3 detik sebelum mengarahkan ke halaman login jika belum mendeteksi sesi aktif.
3.  **Mengklik Tombol Masuk:** Pada layar *Welcome Screen*, ketuk tombol kuning emas bertuliskan **"Masuk dengan Akun Google"**.
4.  **Memilih Akun Google:** Jendela pop-up dari Google Play Services akan muncul. Pilih salah satu akun Google aktif yang ingin digunakan untuk otentikasi.
5.  **Otorisasi dan Sinkronisasi Firestore:** Sistem Firebase Auth memproses kredensial secara asinkron. Jika email tersebut baru terdaftar, sistem secara otomatis membuat dokumen baru di Firebase Firestore pada koleksi `users` dengan nama, email, dan saldo default Rp 0. Setelah selesai, pengguna diarahkan langsung ke halaman beranda utama (*Home Screen*).

    *(Mahasiswa memasukkan Gambar 1.3.1: Halaman Welcome Screen secara manual)*
    `Gambar 1.3.1 Halaman Welcome Screen`

    *(Mahasiswa memasukkan Gambar 1.3.2: Pop-up Otorisasi Google Sign-In secara manual)*
    `Gambar 1.3.2 Pop-up Otorisasi Google Sign-In`

#### 1.3.2.2 Tahap Pengisian Daya Kendaraan
Tahap ini memandu pengguna secara runtun untuk mencari lokasi stasiun, mengaktifkan port pengisian daya, memantau telemetri, dan menyelesaikan sesi transaksi pengisian secara mandiri:
1.  **Menghidupkan Layanan Lokasi:** Pastikan koneksi internet aktif dan GPS pada ponsel telah diaktifkan secara memadai.
2.  **Menemukan Stasiun pada Peta:** Di menu peta utama (*Home Screen*), temukan marker berlogo petir kuning-hijau yang menunjukkan lokasi fisik stasiun SunVolt. Ketuk ikon *crosshair* **"Lokasi Saya"** untuk memusatkan peta pada posisi Anda saat ini.
3.  **Membaca Jarak dan Kartu Stasiun:** Ketuk marker stasiun terdekat. Sebuah panel informasi bawah (*bottom sheet*) akan terangkat yang menampilkan nama stasiun, alamat, status ketersediaan port ("Tersedia"), dan jarak rute berkendara nyata yang dihitung otomatis via API OSRM.
4.  **Membuka Detail Stasiun:** Ketuk tombol **"Pilih Stasiun"** pada panel bawah untuk berpindah ke halaman detail stasiun (*Station Detail Screen*).
5.  **Menghubungkan Konektor Fisik:** Ambil konektor daya fisik dari kabinet stasiun pengisian dan sambungkan secara pas ke kendaraan Anda:
    *   Port DC XT60/XT90 untuk Sepeda Listrik.
    *   Port Stop Kontak AC 220 V untuk Motor Listrik (colokkan bersama adaptor bawaan motor).
6.  **Memilih Port pada Layar:** Di halaman detail stasiun, pilih tipe port pengisian daya sesuai kendaraan Anda (opsi "Sepeda Listrik" atau "Motor Listrik"). Layar akan otomatis menampilkan estimasi kalkulasi daya dan rincian tarif berjalan.
7.  **Melakukan Cek Saldo Minimum:** Ketuk tombol **"Mulai Isi Daya"**. Sistem secara otomatis mendeteksi saldo e-wallet Anda:
    *   Jika saldo di bawah Rp 10.000, tombol dinonaktifkan dengan peringatan merah: *"Saldo Anda tidak mencukupi! Minimal Rp 10.000 untuk pengisian."*
    *   Jika saldo mencukupi (>= Rp 10.000), jendela konfirmasi akan terbuka. Ketuk **"Ya, Mulai"**.
8.  **Aktuasi Relay Pengisian:** Aplikasi akan mengirim perintah ke Firestore `sunvolt-admin` untuk mengaktifkan relay fisik stasiun. Sesi pengisian aktif dimulai dan tampilan layar dialihkan ke halaman pemantauan kelistrikan aktif (*Active Charging Status Screen*).
9.  **Memantau Telemetri secara Real-Time:** Pengguna memantau indikator status pengisian reaktif yang menampilkan data live: Daya aktif (Watt), akumulasi energi tersalurkan (kWh), tarif biaya berjalan (Rupiah), serta suhu internal boks stasiun.
10. **Ketahanan Sesi Aktif (Auto-Resume):** Apabila ponsel Anda mati atau aplikasi tertutup paksa secara tidak sengaja sewaktu pengisian sedang berlangsung, **aliran listrik fisik stasiun tidak akan terputus**. Anda cukup membuka kembali aplikasi SunVolt dan sistem akan secara otomatis mengembalikan tampilan layar ke halaman pemantauan status pengisian aktif tanpa kehilangan kalkulasi KWh dan tarif berjalan.
11. **Mengakhiri Pengisian:** Sesi pengisian akan mati otomatis saat baterai kendaraan penuh (arus sensor INA219 turun di bawah 0,05 A selama 30 detik) atau saldo Anda habis. Anda juga dapat mengakhirinya secara manual kapan saja dengan mengetuk tombol merah **"Berhenti Mengisi"** pada layar dan menyetujui konfirmasi dialog.
12. **Pemotongan Saldo Akhir (Settlement):** Sistem mematikan relay fisik stasiun secara live, menghitung tagihan biaya akhir, memotong saldo dompet digital Anda secara atomik di database Firestore Utama, mencatat rincian transaksi pengisian pada sub-koleksi `activity_history`, dan memunculkan halaman bukti transaksi selesai (*Receipt Screen*). Cabut kabel konektor daya dari port fisik stasiun.

    *(Mahasiswa memasukkan Gambar 1.3.3: Visualisasi Peta dan Marker Stasiun secara manual)*
    `Gambar 1.3.3 Visualisasi Peta dan Marker Stasiun`

    *(Mahasiswa memasukkan Gambar 1.3.4: Halaman Detail Stasiun secara manual)*
    `Gambar 1.3.4 Halaman Detail Stasiun`

    *(Mahasiswa memasukkan Gambar 1.3.5: Halaman Pemantauan Telemetri Aktif secara manual)*
    `Gambar 1.3.5 Halaman Pemantauan Telemetri Aktif`

    *(Mahasiswa memasukkan Gambar 1.3.6: Tampilan Resi Rincian Biaya Akhir secara manual)*
    `Gambar 1.3.6 Tampilan Resi Rincian Biaya Akhir`

#### 1.3.2.3 Tahap Top Up Saldo Dompet
Tahap ini menjelaskan prosedur pengisian ulang saldo e-wallet SunVolt menggunakan QRIS Sandbox Midtrans secara terperinci:
1.  **Membuka Menu Dompet:** Ketuk ikon tab **"Dompet"** pada bilah navigasi bawah aplikasi (*Bottom Navigation Bar*). Layar akan menampilkan total saldo aktif Anda saat ini.
2.  **Memilih Nominal Top-up:** Pilih salah satu nominal pengisian ulang yang tersedia pada grid pilihan cepat (misalnya: Rp 10.000, Rp 20.000, atau Rp 50.000), kemudian ketuk tombol **"Top Up Sekarang"**.
3.  **Mengonfirmasi Invoice:** Layar akan beralih ke halaman ringkasan tagihan. Periksa nominal transfer, lalu ketuk tombol **"Bayar Sekarang"**.
4.  **Membuka Halaman Web Midtrans Snap:** Aplikasi memanggil API backend serverless di Vercel untuk meminta Snap redirect URL dari Midtrans. Aplikasi secara otomatis membuka browser eksternal ponsel yang menampilkan halaman transaksi Midtrans Sandbox.
5.  **Memilih Metode QRIS:** Pada halaman web Midtrans Snap, pilih opsi metode pembayaran **"QRIS"**. Halaman web akan memuat kode QR statis untuk pengujian. Simpan tangkapan layar (*screenshot*) kode QR tersebut.
6.  **Melakukan Pembayaran Simulasi:** Buka aplikasi simulator pembayaran QRIS Midtrans Sandbox, unggah/pindai tangkapan layar kode QR tadi, lalu ketuk tombol simulator **"Pay / Sukses"** untuk menyelesaikan proses pelunasan secara simulasi.
7.  **Pembaruan Saldo dan Riwayat Transaksi:** Midtrans mengirimkan notifikasi callback settlement ke server backend Vercel. Server backend memproses webhook secara aman, memperbarui saldo Firestore Anda secara atomik (increment), dan mencatat log transaksi top-up pada sub-koleksi `activity_history`.
8.  **Animasi Keberhasilan Pembayaran:** Aplikasi mobile SunVolt secara otomatis mendeteksi perubahan nilai saldo di Firestore, memindahkan tampilan ke halaman status **"Pembayaran Berhasil"** dengan centang hijau animasi, dan memperbarui angka nominal saldo di tab menu Dompet Anda.

    *(Mahasiswa memasukkan Gambar 1.3.7: Halaman Input Nominal Top-Up Dompet secara manual)*
    `Gambar 1.3.7 Halaman Input Nominal Top-Up Dompet`

    *(Mahasiswa memasukkan Gambar 1.3.8: Tampilan QR Code Sandbox Midtrans Snap secara manual)*
    `Gambar 1.3.8 Tampilan QR Code Sandbox Midtrans Snap`

    *(Mahasiswa memasukkan Gambar 1.3.9: Animasi Notifikasi Pembayaran Berhasil secara manual)*
    `Gambar 1.3.9 Animasi Notifikasi Pembayaran Berhasil`

---

### 1.3.3 Prosedur Pengoperasian Perangkat Lunak (Software) Web Admin Monitoring SunVolt Hub

#### 1.3.3.1 Prasyarat Website Admin
Sebelum mengakses dasbor web admin monitoring, penuhi prasyarat pada Tabel 1.3.3:

**Tabel 1.3.3 Tabel Prasyarat Website Admin**

| No | Prasyarat | Keterangan |
| :--- | :--- | :--- |
| 1 | Browser Modern | Browser Chrome, Edge, Firefox, atau Safari versi terbaru |
| 2 | Koneksi Internet | Jaringan internet aktif untuk memuat Firestore SDK |
| 3 | Akun Whitelist | Akun email terdaftar: firecalm2@gmail.com, syauqiakmal137@gmail.com, atau fattaha.rasyad@gmail.com |
| 4 | Stasiun Aktif | Perangkat ESP32 stasiun menyala mengirimkan data |

#### 1.3.3.2 Prosedur 1 Akses dan Login
1.  Buka browser komputer, lalu arahkan menuju URL deployment web admin.
2.  Layar login memuat tulisan **"SECURE ADMIN ACCESS"**. Klik tombol **"Continue with Google"**.
3.  Selesaikan verifikasi otentikasi Google login.
    *   Jika email terdaftar: Anda akan dialihkan langsung ke dashboard tab Overview.
    *   Jika email ditolak: Halaman masuk memunculkan bar peringatan merah **"Security Alert: Akses Ditolak"** dan memutus paksa koneksi.

    *(Mahasiswa memasukkan Gambar 1.3.11: Halaman Login Admin secara manual)*
    `Gambar 1.3.11 Halaman Login Admin`

    *(Mahasiswa memasukkan Gambar 1.3.12: Halaman Jika Email Tidak Terdaftar secara manual)*
    `Gambar 1.3.12 Halaman Jika Email Tidak Terdaftar`

#### 1.3.3.3 Prosedur 2 Memantau Tab Overview
1.  Buka bilah tab menu **"Overview"** di dasbor bawah.
2.  Di bagian kiri, administrator memantau tinggi pengisian tangki baterai stasiun (%) melalui animasi fill baterai hijau real-time.
3.  Di bagian kanan, meninjau panel *Active Session* untuk melihat e-mail identitas pengguna kampus yang sedang mencolokkan kendaraan, besar arus kelistrikan keluar (A), dan status relay.

    *(Mahasiswa memasukkan Gambar 1.3.13: Halaman Beranda Admin secara manual)*
    `Gambar 1.3.13 Halaman Beranda Admin`

#### 1.3.3.4 Prosedur 3 Membaca Tab Diagnostics
1.  Klik bilah tab menu **"Diagnostics"** di bagian bawah dasbor.
2.  Administrator meninjau status tegangan panel surya ($PV_{Voltage}$), arus solar panel ($PV_{Current}$), suhu internal BMS stasiun, suhu heatsink booster, dan kekuatan tangkapan sinyal RSSI stasiun.
3.  Lihat grafik tren tegangan berjalan di bagian bawah untuk menganalisis naik-turun tegangan panel surya sepanjang hari.

    *(Mahasiswa memasukkan Gambar 1.3.14: Halaman Diagnosa secara manual)*
    `Gambar 1.3.14 Halaman Diagnosa`

#### 1.3.3.5 Prosedur 4 Membaca Log Sistem dan Ekspor Data
1.  Tekan bilah tab menu **"Logs"** di bagian bawah dasbor.
2.  Layar memetakan log peristiwa status stasiun pengisian. Baris paling atas dengan tulisan hijau berdenyut menunjukkan aktivitas telemetri paling baru.
3.  Klik tombol **"Export Data (.xlsx)"** di pojok kanan atas tab untuk mengunduh log telemetri historis dalam format spreadsheet Excel secara instan.

    *(Mahasiswa memasukkan Gambar 1.3.15: Halaman Log Sistem dan Ekspor Data secara manual)*
    `Gambar 1.3.15 Halaman Log Sistem dan Ekspor Data`

#### 1.3.3.6 Prosedur 5 Sign Out
1.  Untuk mengakhiri sesi admin, klik tombol **"Sign Out"** yang berada di header kiri dasbor tepat di bawah nama email admin.
2.  Browser secara asinkron membersihkan seluruh variabel state login, memutuskan listener snapshots Firestore, dan mengarahkan admin kembali ke halaman login.

#### 1.3.3.7 Prosedur 6 Memperbarui Web
1.  Buka kode proyek repositori lokal web menggunakan editor Visual Studio Code di komputer.
2.  Setelah melakukan modifikasi kode dan mengujinya secara lokal (`npm run dev`), jalankan perintah git berikut pada terminal VSCode:
    
    ```bash
    git add .
    git commit -m "deskripsi perubahan yang dilakukan"
    git push origin main
    ```
3.  Proyek repositori GitHub yang terintegrasi ke Vercel secara otomatis akan mendeteksi pembaharuan commit terbaru pada branch main.
4.  Vercel memulai proses build asinkron di server cloud (membutuhkan waktu 1-2 menit). Setelah selesai, versi website admin terbaru langsung mengudara secara langsung tanpa mengganggu jalannya database.

---

## Daftar Pustaka
```
[1]  A. C. CAREND, "ANALISIS EFISIENSI SOLAR PANEL DENGAN KAPASITAS 200 WP DI POLITEKNIK NEGERI SRIWIJAYA," Skripsi, Politeknik Negeri Sriwijaya, Palembang, 2022.
[2]  I. Rudiatmadja, "Rancang Bangun Dan Monitoring Charger Baterai Dengan Metode Charging Otomatis Menggunakan Rangkaian Sensor Tegangan Dan Regulator Arus Berbasis Arduino Mega 2560," Jurnal Transmisi, vol. 20, no. 3, pp. 112-119, 2018.
[3]  Adafruit Industries, "Adafruit INA219 High-Side DC Current Sensor Breakout Datasheet," Adafruit, 2022. [Online]. Available: https://learn.adafruit.com/adafruit-ina219-current-sensor-breakout.
[4]  Espressif Systems, "ESP32-WROOM-32U Series Datasheet v2.1," Espressif, 2023. [Online]. Available: https://www.espressif.com/documentation/esp32-wroom-32u_datasheet_en.pdf.
[5]  Midtrans Developer Portal, "Midtrans Snap Core API Integration Guide," Midtrans, 2024. [Online]. Available: https://docs.midtrans.com/.
[6]  Vercel Inc., "Vercel Serverless Functions Deployment Documentation," Vercel, 2025. [Online]. Available: https://vercel.com/docs/concepts/functions/serverless-functions.
[7]  F. Hutajulu dan N. A. Diandra, "Solar Charging Station untuk Sepeda Listrik," Laporan Buku Tugas Akhir Capstone Design, S1 Teknik Komputer, Universitas Telkom, Bandung, 2026.
```
