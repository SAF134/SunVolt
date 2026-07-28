# BAB I
# USULAN GAGASAN

## 1.1 Deskripsi Umum Masalah dan Kebutuhan
Krisis energi global dan dampak negatif perubahan iklim akibat emisi gas rumah kaca telah mendorong berbagai negara untuk beralih dari energi fosil menuju energi terbarukan dan ramah lingkungan [1]. Sebagai komitmen dalam menanggulangi dampak perubahan iklim global, pemerintah Indonesia melalui dokumen *Enhanced Nationally Determined Contribution* (E-NDC) berkomitmen menurunkan emisi karbon sebesar 31,89% hingga 43,2% (dengan bantuan internasional) pada tahun 2030, serta menargetkan *Net Zero Emission* (NZE) pada tahun 2060 atau lebih cepat [2].

Salah satu sektor penyumbang emisi karbon terbesar di Indonesia adalah sektor transportasi. Oleh karena itu, dekarbonisasi transportasi melalui adopsi kendaraan listrik (*Electric Vehicle*/EV) menjadi salah satu program prioritas nasional. Pertumbuhan kendaraan listrik di Indonesia, khususnya kendaraan roda dua, menunjukkan tren kenaikan yang sangat pesat. Berdasarkan data Kementerian Perhubungan melalui Surat Registrasi Uji Tipe (SRUT) hingga akhir tahun 2025, populasi sepeda motor listrik di Indonesia telah melampaui **225.647 unit**, dengan kontribusi sektor roda dua mencakup sekitar 65% dari total ekosistem kendaraan listrik nasional [3]. Pertumbuhan ini tidak hanya terbatas pada sepeda motor listrik komersial, tetapi juga meluas pada kepemilikan sepeda listrik (*electric bicycle*) sebagai alat transportasi mikro jarak pendek.

Di lingkungan akademis, Universitas Telkom (Telkom University) berkomitmen mewujudkan visi *Green Campus* secara berkelanjutan melalui partisipasi aktif dalam UI GreenMetric, penyediaan moda transportasi ramah lingkungan, serta fasilitas infrastruktur energi bersih [4]. Kehadiran mahasiswa dan staf yang menggunakan Kendaraan Listrik Ringan (*Lightweight Electric Vehicle*/LEV), seperti sepeda listrik dan sepeda motor listrik di dalam area kampus, semakin meningkat dari tahun ke tahun.

Namun, peningkatan populasi LEV di lingkungan kampus Universitas Telkom menghadapi kendala utama berupa **minimnya infrastruktur pengisian daya (*charging station*) yang mandiri, aman, dan transparan**. Permasalahan krusial yang diidentifikasi di lapangan saat ini meliputi:
1. **Ketergantungan pada Jaringan Listrik PLN (*On-Grid*):** Sebagian besar fasilitas pengisian daya yang tersedia di kampus masih memanfaatkan pasokan listrik jala-jala PLN yang bersumber dari pembangkit berbahan bakar fosil (batubara/gas), sehingga bertentangan dengan prinsip dekarbonisasi *Green Campus*.
2. **Ketiadaan Pembagian Daya Dual Output (AC & DC):** Stasiun pengisian yang ada umumnya bersifat ad-hoc dan tidak dirancang secara khusus untuk melayani dua jenis LEV sekaligus. Sepeda listrik membutuhkan pengisian daya DC yang stabil (misalnya 54.6 V), sedangkan sepeda motor listrik memerlukan keluaran AC (220 V) untuk dihubungkan ke pengisi daya eksternal bawaan pabrik.
3. **Ketiadaan Sistem Monitoring dan Kontrol IoT yang Transparan:** Pengguna LEV tidak dapat memantau parameter pengisian daya (arus, tegangan, daya yang masuk) serta akumulasi tarif secara langsung melalui perangkat seluler mereka. Di sisi lain, administrator stasiun pengisian (pihak kampus) juga tidak memiliki kontrol terpusat dari jarak jauh untuk memutus atau mengalirkan arus (*relay switching*) demi alasan keselamatan kelistrikan, pencegahan *overcharging*, dan pengelolaan antrean.

Oleh karena itu, dibutuhkan sebuah solusi inovatif berupa **"Sistem Pengisian Daya Kendaraan Listrik Ringan Berbasis Tenaga Surya"** yang beroperasi secara mandiri (*off-grid*), dilengkapi dual output pengisian (AC dan DC), serta terintegrasi penuh dengan mikrokontroler berbasis IoT, aplikasi mobile untuk pengguna (**SunVolt**), dan dashboard admin web untuk pemantauan dan kontrol terpusat.

---

## 1.2 Analisa Masalah
Analisis masalah dilakukan secara mendalam dengan meninjau beberapa aspek penting untuk mendukung kebutuhan proyek tugas akhir ini secara komprehensif.

### 1.2.1 Aspek Teknis (Keilmuan Teknik Komputer / Embedded System)
Dari sudut pandang teknik komputer, sistem kelistrikan mandiri (*off-grid*) berbasis Pembangkit Listrik Tenaga Surya (PLTS) memiliki tantangan kompleks dalam manajemen daya, akuisisi data sensor, dan kendali nirkabel:
* **Integrasi Dual Output AC-DC pada Sistem 48V:** Berbeda dengan sistem sebelumnya yang menggunakan bank baterai 12V paralel dengan rugi-rugi daya (*power losses*) yang sangat besar saat dinaikkan ke 54.6V, sistem baru ini dirancang menggunakan baterai seri dengan tegangan nominal **48V**. Hal ini memerlukan perancangan jalur distribusi daya ganda:
  * Jalur DC dengan *DC-DC Boost Converter* untuk menyuplai daya sepeda listrik (54.6 V, 20 A).
  * Jalur AC melalui *Inverter Pure Sine Wave* (1000 W, 220 V AC) untuk menyuplai daya sepeda motor listrik.
* **Akurasi Akuisisi Data Kelistrikan (Telemetri):** Penggunaan sensor arus berbasis efek Hall seperti ACS712 pada sistem sebelumnya menghasilkan *noise* yang tinggi dan akurasi rendah untuk pembacaan arus kecil. Dibutuhkan peningkatan teknologi telemetri menggunakan **sensor INA219** yang menggunakan antarmuka komunikasi I2C untuk membaca tegangan, arus, dan daya secara digital dengan tingkat presisi dan resolusi yang jauh lebih tinggi.
* **Keamanan dan Sinkronisasi Data Real-Time:** Kendali *remote switching* (relay AC/DC) memerlukan alur komunikasi dengan latensi rendah (*low-latency*) agar perintah dari web admin dapat langsung dieksekusi oleh mikrokontroler **ESP32 DevKit V4** di stasiun pengisian. Sinkronisasi data telemetri ke Firebase juga harus memiliki ketahanan tinggi (*session resiliency*), sehingga apabila koneksi internet terputus atau aplikasi pengguna mati secara paksa, proses pengisian dan penghitungan tarif tetap berjalan secara konsisten di tingkat lokal mikrokontroler.

### 1.2.2 Aspek Lingkungan dan Keberlanjutan
Penggunaan sumber energi konvensional untuk mengisi daya kendaraan listrik di kampus tetap menghasilkan jejak karbon tidak langsung (*indirect carbon footprint*). Dengan merancang stasiun pengisian berbasis **PLTS Off-Grid** menggunakan 4 unit panel surya 100 Wp dan MPPT (Maximum Power Point Tracking) SCC 48V 60A, stasiun pengisian ini dapat memanen dan menyimpan energi matahari ke bank baterai secara mandiri. Hal ini berkontribusi langsung pada pengurangan emisi karbon lokal (CO2) di lingkungan Universitas Telkom dan mendukung program pelestarian lingkungan kampus.

### 1.2.3 Aspek Sosial dan Ekonomi
* **Kebutuhan Transparansi Tarif:** Saat ini, mahasiswa sering kesulitan memperkirakan biaya pengisian daya LEV di kampus. Dengan integrasi sensor presisi tinggi (INA219), sistem dapat mengalkulasi konsumsi daya riil dalam satuan Watt-hour (Wh) atau kilowatt-hour (kWh), lalu mengonversinya menjadi tarif rupiah secara transparan di aplikasi **SunVolt**.
* **Kemudahan Akses dan Pembayaran:** Integrasi sistem pembayaran digital nontunai (simulasi QRIS/Midtrans) di dalam aplikasi mempermudah pengguna melakukan pengisian ulang saldo (*top-up*) tanpa harus melakukan transaksi tunai secara konvensional, meningkatkan efisiensi waktu, serta memberikan pengalaman transaksi yang aman dan tercatat secara historis di database Firestore.

---

## 1.3 Kompleksitas Permasalahan
Dalam penulisan dokumen usulan gagasan ini, analisis kompleksitas permasalahan dilakukan untuk mengukur kelayakan topik tugas akhir agar memenuhi standar perancangan rekayasa komputer. Tabel 1 merinci kriteria kompleksitas yang terpenuhi dalam perancangan sistem ini.

**Tabel 1. Kompleksitas Permasalahan**

| No | Kriteria Kompleksitas | Penjelasan |
| :--- | :--- | :--- |
| 1 | **Penyelesaian permasalahan memerlukan pengetahuan keteknikan yang mendalam.** *(Wajib)* | Perancangan sistem ini menuntut integrasi lintas disiplin ilmu elektronika daya (penggunaan inverter gelombang sinus murni, DC-DC converter, manajemen baterai SLA 48V, MPPT SCC) dan teknologi informasi (pemrograman embedded C++ pada ESP32, arsitektur database NoSQL real-time Firebase, enkripsi komunikasi IoT, dan pengembangan aplikasi Flutter menggunakan state management terpusat). |
| 2 | **Permasalahan melibatkan isu-isu yang luas, saling bersinggungan, dan melibatkan masalah non-teknis.** | Proyek ini tidak hanya berfokus pada efisiensi konversi daya secara teknis, tetapi juga bersinggungan dengan kebijakan *Green Campus* Universitas Telkom (aspek lingkungan), perilaku adopsi kendaraan listrik mahasiswa (aspek sosial), serta perhitungan tarif energi berbasis kWh dan integrasi gerbang pembayaran digital Midtrans (aspek ekonomi/finansial). |
| 3 | **Solusi yang jelas belum tersedia sehingga diperlukan abstraksi pemikiran untuk memformulasikan model solusi yang sesuai.** | Belum ada standar komersial yang mengintegrasikan stasiun pengisian daya LEV tenaga surya off-grid bersistem 48V dengan *dual output AC-DC* yang dikendalikan oleh administrator web-IoT dari jarak jauh dan dipantau oleh aplikasi pengguna secara *real-time*. Diperlukan abstraksi logika program pada ESP32 untuk mendeteksi *auto-cut off* jika pengisian selesai (arus mendekati 0A) atau jika saldo pengguna habis, yang harus disinkronkan secara aman antara Firebase, Web Admin, dan Aplikasi SunVolt. |
| 4 | **Permasalahan tingkat tinggi yang meliputi beberapa bagian.** | Permasalahan dibagi menjadi tiga bagian besar yang saling bergantung secara kritis: (a) *Hardware & Power Management* (panel surya, baterai, proteksi sekring/AC-DC breaker, inverter, boost converter), (b) *Embedded Telemetry & Control* (sensor INA219, suhu, mikrokontroler ESP32, dual relay), dan (c) *Software Application* (aplikasi mobile Flutter, backend Node.js, Firebase Cloud, dan admin monitoring dashboard web). |

---

## 1.4 Analisa Solusi yang Ada
Untuk mempertegas kontribusi dan kebaruan (*novelty*) dari sistem yang diusulkan, dilakukan analisis komparatif terhadap solusi sejenis yang telah ada sebelumnya.

1. **Solusi Eksisting 1: Stasiun Pengisian Daya Sepeda Listrik (Capstone Sebelumnya) [5]**
   * *Deskripsi:* Purwarupa stasiun pengisian tenaga surya off-grid yang dirancang khusus untuk melayani pengisian daya sepeda listrik.
   * *Keunggulan (Strength):* Sudah menggunakan teknologi panel surya mandiri (*off-grid*) dan mendukung *step-up booster* untuk pengisian sepeda listrik 48V dari input aki 12V.
   * *Kekurangan (Weakness):* Hanya menyediakan satu jalur pengisian DC (sepeda listrik), tidak dapat menyuplai motor listrik yang membutuhkan colokan AC 220V. Sensor arus ACS712 yang digunakan memiliki kerentanan tinggi terhadap interferensi elektromagnetik (*noise*), sehingga pembacaan arus tidak stabil.
   * *Keterbatasan (Limitation):* Tidak dilengkapi dashboard admin berbasis website untuk memantau stasiun secara terpusat dan mengontrol relay secara nirkabel dari sisi pengelola kampus. Sistem penyimpanan menggunakan aki 12V paralel yang memerlukan peningkatan tegangan (*boost*) sangat besar, sehingga menyebabkan efisiensi konversi daya rendah (84% dengan *losses* panas ~16%).

2. **Solusi Eksisting 2: SPKLU (Stasiun Pengisian Kendaraan Listrik Umum) On-Grid PLN [6]**
   * *Deskripsi:* Infrastruktur pengisian kendaraan listrik skala besar yang disediakan oleh PLN untuk mobil dan motor listrik yang terhubung ke jaringan listrik utama.
   * *Keunggulan (Strength):* Daya keluaran sangat besar, andal, dan mendukung protokol *fast charging* standar industri.
   * *Kekurangan (Weakness):* Bergantung sepenuhnya pada jaringan listrik PLN (*on-grid*) yang masih didominasi sumber energi batu bara, sehingga kontribusi terhadap dekarbonisasi murni kurang optimal. Biaya instalasi infrastruktur sangat mahal.
   * *Keterbatasan (Limitation):* Tidak dirancang untuk pengisian daya kendaraan listrik ringan (*lightweight*) kelas sepeda listrik mahasiswa, dan tidak terintegrasi dengan ekosistem digital kampus untuk penerapan tarif khusus sivitas akademika.

---

## 1.5 Kesimpulan
Berdasarkan pemaparan usulan gagasan di atas, urgensi dari pembuatan **"Sistem Pengisian Daya Kendaraan Listrik Ringan Berbasis Tenaga Surya"** didorong oleh meningkatnya populasi kendaraan listrik ringan (sepeda dan motor listrik) di lingkungan kampus Universitas Telkom yang belum diimbangi oleh ketersediaan fasilitas pengisian daya yang ramah lingkungan dan transparan. 

Kompleksitas permasalahan dalam sistem ini terletak pada perancangan dual output distribusi daya (AC 220V dan DC 54.6V) dari bank baterai seri 48V, akuisisi data telemetri kelistrikan berakurasi tinggi menggunakan sensor INA219, serta sinkronisasi logika IoT (ESP32) untuk fungsi keamanan *auto cut-off* dengan Firebase, aplikasi mobile **SunVolt**, dan dashboard monitoring web admin. 

Sistem yang diusulkan ini berhasil mengatasi keterbatasan solusi sebelumnya dengan menghadirkan dukungan pengisian daya motor listrik (AC) dan sepeda listrik (DC) secara simultan, meningkatkan akurasi data sensor melalui protokol I2C, serta memberikan kendali penuh bagi administrator kampus untuk memantau dan mengontrol keamanan operasional stasiun pengisian secara terpusat demi mewujudkan ekosistem *Green Campus* yang handal.

---

## Daftar Pustaka

```
[1]  International Energy Agency (IEA), "Global EV Outlook 2025: Towards sustainable electric mobility integration," IEA Publications, Paris, Tech. Rep., May 2025.
[2]  Kementerian Lingkungan Hidup dan Kehutanan (KLHK) Republik Indonesia, "Dokumen Enhanced Nationally Determined Contribution (E-NDC) Indonesia," KLHK, Jakarta, Indonesia, 2022.
[3]  Direktorat Jenderal Perhubungan Darat - Kementerian Perhubungan RI, "Laporan Statistik SRUT Kendaraan Bermotor Listrik Nasional per Desember 2025," Kemenhub RI, Jakarta, Tech. Rep., Jan. 2026.
[4]  Telkom University Sustainability Office, "Green Campus Initiatives and Carbon Footprint Reduction Report 2025," Telkom University, Bandung, Indonesia, 2025.
[5]  F. Hutajulu dan N. A. Diandra, "Solar Charging Station untuk Sepeda Listrik," Laporan Buku Tugas Akhir Capstone Design, S1 Teknik Komputer, Universitas Telkom, Bandung, 2026.
[6]  PT PLN (Persero), "Rencana Usaha Penyediaan Tenaga Listrik (RUPTL) 2021-2030: Transisi menuju infrastruktur SPKLU nasional," PLN, Jakarta, Tech. Rep., 2021.
[7]  A. Maghfuri, C. Sudjoko, B. S. Arifianto, dan Y. D. Kuntjoro, "A Critical Review of Potential Development of Photovoltaic (PV) Systems at Electric Vehicle Charging Stations to Support Clean Energy in Indonesia," Jurnal Energi dan Kelistrikan, vol. 13, no. 1, hlm. 45-56, Jun. 2021.
[8]  R. Septian dan S. M. Prasetiyo, "Sistem Monitoring Kelistrikan Berbasis Internet of Things (IoT) pada Stasiun Pengisian Daya Mandiri," Jurnal Ilmu Komputer dan Science, vol. 10, no. 2, hlm. 112-120, Des. 2023.
```
