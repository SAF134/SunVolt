import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SunVoltAppBar(
            showBackButton: true,
            title: 'Bantuan & FAQ',
            trailing: const SizedBox.shrink(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryGrid(),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Panduan Penggunaan Stasiun'),
                  _buildStepCard(
                    '1',
                    'Scan QR Code',
                    'Datang ke stasiun pengguna terdekat, tekan tombol Scan di menu Peta, lalu arahkan kamera ke QR code yang ada di mesin pengisian.',
                  ),
                  _buildStepCard(
                    '2',
                    'Pilih Kendaraan & Cek Saldo',
                    'Pastikan memilih profil kendaraan yang sesuai (Sepeda atau Motor) agar tegangan dan tarif sesuai. Periksa juga saldo dompet Anda.',
                  ),
                  _buildStepCard(
                    '3',
                    'Hubungkan Kabel',
                    'Colokkan kabel pengisian dengan aman ke port kendaraan Anda sebelum menekan tombol "Mulai Isi Daya".',
                  ),
                  _buildStepCard(
                    '4',
                    'Selesai & Cabut',
                    'Pengisian akan otomatis berhenti saat baterai penuh atau saldo habis. Cabut kabel dengan aman dan letakkan pada tempatnya.',
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Panduan Top Up Saldo Dompet'),
                  _buildStepCard(
                    '1',
                    'Buka Menu Dompet',
                    'Klik tab "Dompet" pada navigasi bawah atau pilih kartu Saldo di halaman beranda.',
                  ),
                  _buildStepCard(
                    '2',
                    'Pilih Tombol Top Up',
                    'Tekan tombol emas "Top Up Sekarang" untuk memunculkan pilihan pengisian saldo.',
                  ),
                  _buildStepCard(
                    '3',
                    'Scan & Bayar Sandbox Midtrans',
                    'Gunakan aplikasi e-wallet (GoPay, OVO, Dana) atau Mobile Banking Anda untuk memindai kode Sandbox Midtrans yang tampil.',
                  ),
                  _buildStepCard(
                    '4',
                    'Saldo Bertambah',
                    'Setelah pembayaran sukses, saldo Anda akan diperbarui secara otomatis dalam hitungan detik.',
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('FAQ: Pengisian Daya'),
                  _buildFaqItem(
                    'Berapa tarif pengisian listrik di SunVolt?',
                    'Tarif listrik di seluruh stasiun SunVolt adalah Rp 2.500 per kWh. Biaya dihitung secara presisi hanya berdasarkan energi yang benar-benar masuk ke baterai kendaraan Anda, bukan berdasarkan durasi atau waktu colok.',
                  ),
                  _buildFaqItem(
                    'Bagaimana aturan ketersediaan slot pengisian daya?',
                    'Pengguna dapat mengisi daya sepeda listrik ketika Relay DC aktif dan slot Sepeda berstatus "Tersedia". Begitu pula untuk motor listrik, pengisian dapat dilakukan ketika Relay AC aktif dan slot Motor berstatus "Tersedia". Jika salah satu slot sedang digunakan oleh orang lain ("Sedang Dipakai"), Anda harus menunggu hingga pengguna tersebut selesai.',
                  ),
                  _buildFaqItem(
                    'Berapa minimum saldo untuk mulai mengisi?',
                    'Demi kelancaran dan keamanan pengisian daya, batas saldo minimum adalah:\n• Sepeda Listrik (Relay DC): Rp 2.400\n• Motor Listrik (Relay AC): Rp 5.400',
                  ),
                  _buildFaqItem(
                    'Bagaimana jika saldo habis di tengah jalan?',
                    'Tidak perlu khawatir. SunVolt Smart System akan menghentikan aliran listrik secara otomatis saat biaya berjalan telah mencapai batas saldo Anda. Aliran daya (Relay AC/DC) akan otomatis dimatikan.',
                  ),
                  _buildFaqItem(
                    'Bagaimana sistem memonitor daya secara akurat?',
                    'Stasiun SunVolt terintegrasi dengan perangkat IoT (Internet of Things) menggunakan Mikrokontroler ESP32, Relay AC/DC, dan Sensor Arus ACS712. Pemakaian arus dibaca secara presisi setiap detiknya dan dikirim ke aplikasi secara real-time.',
                  ),
                  _buildFaqItem(
                    'Profil pengisian CC-CV itu apa?',
                    'CC-CV adalah singkatan dari Constant Current (Arus Konstan) dan Constant Voltage (Tegangan Konstan). Mesin akan mengisi arus maksimal saat baterai masih kosong (CC), dan perlahan menurunkan arus saat baterai hampir penuh (CV) untuk melindungi sel baterai agar lebih awet.',
                  ),
                  _buildFaqItem(
                    'Bagaimana cara menampilkan rute ke stasiun pengisian?',
                    'Pada menu peta beranda, ketuk penanda (marker) stasiun SunVolt. Lalu, tekan tombol "Lokasi Saya" (ikon GPS kuning) di bagian kanan atas. Aplikasi akan langsung memetakan rute rute jalan terpendek dengan garis gradien kuning-ke-hijau, lengkap dengan estimasi jarak dan durasi perjalanan.',
                  ),
                  _buildFaqItem(
                    'Bagaimana cara menghentikan pengisian daya?',
                    'Untuk mencegah terputusnya pengisian daya secara tidak sengaja, SunVolt mengganti tombol klik biasa dengan metode usap (swipe gesture). Cukup geser tombol slider putih bertuliskan "Geser untuk Berhenti" dari kiri ke kanan untuk mematikan aliran listrik.',
                  ),
                  _buildFaqItem(
                    'Apakah saya bisa meminimalkan aplikasi saat pengisian daya berlangsung?',
                    'Ya, tentu saja. Aplikasi SunVolt dilengkapi dengan fitur sinkronisasi latar belakang. Jika Anda menekan tombol beranda atau meminimalkan aplikasi, sistem akan terus menghitung dan mengakumulasikan pemakaian energi secara real-time. Begitu aplikasi dibuka kembali, data persentase dan biaya pengisian akan diperbarui secara instan.',
                  ),
                  _buildFaqItem(
                    'Bagaimana cara menggunakan panel informasi stasiun?',
                    'Kami menyediakan lembar detail stasiun bertema Glassmorphism di bagian bawah peta. Anda dapat menyeret (drag) panel tersebut ke atas menggunakan jari untuk membacanya, atau mengusapnya ke bawah untuk menutupnya dengan efek pegas elastis yang halus.',
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('FAQ: Dompet & Pembayaran'),
                  _buildFaqItem(
                    'Metode Top-Up apa saja yang didukung?',
                    'Saat ini kami mendukung metode Sandbox Midtrans. Anda bisa menggunakan berbagai e-wallet (GoPay, OVO, Dana) dan Mobile Banking yang mendukung pembayaran Sandbox Midtrans. Saldo akan otomatis bertambah secara real-time.',
                  ),
                  _buildFaqItem(
                    'Apakah ada biaya admin untuk Top-Up?',
                    'Biaya layanan/admin mungkin berlaku bergantung kepada penyedia dompet digital atau bank yang Anda gunakan. SunVolt tidak mengenakan biaya admin tambahan saat Top-Up.',
                  ),
                  _buildFaqItem(
                    'Uang saya terpotong tapi saldo tidak bertambah?',
                    'Jika hal ini terjadi, tutup aplikasi Anda lalu buka kembali (refresh). Jika saldo belum juga masuk dalam waktu 10 menit, segera hubungi tim Support dengan melampirkan bukti transfer. Kami akan menyelesaikan masalah Anda segera.',
                  ),
                  _buildFaqItem(
                    'Apakah metode pembayaran Sandbox Midtrans aman?',
                    'Sangat aman. Setiap transaksi top-up menggunakan metode digital (Qris / E-Wallet) langsung divalidasi oleh sistem server backend kami menggunakan verifikasi tanda tangan kriptografi SHA-512 untuk mencegah manipulasi data saldo.',
                  ),
                  _buildFaqItem(
                    'Bagaimana cara kerja metode Geser untuk Membayar?',
                    'Pada layar pembayaran, cukup geser tombol bertuliskan "Geser untuk Membayar" ke kanan. Hal ini akan langsung membuat transaksi dan mengarahkan Anda ke halaman tagihan resmi Sandbox Midtrans tanpa melalui pop-up konfirmasi yang berlebihan.',
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('FAQ: Keamanan & Akun'),
                  _buildFaqItem(
                    'Perangkat apa saja yang didukung oleh SunVolt?',
                    'Aplikasi SunVolt saat ini dirancang eksklusif dan hanya dapat diakses melalui perangkat mobile Android demi kinerja dan kecocokan integrasi hardware yang optimal. Tidak mendukung iOS, macOS, Windows, Linux, maupun Web.',
                  ),
                  _buildFaqItem(
                    'Aman tidak mengisi daya saat hujan?',
                    'Stasiun SunVolt dilengkapi desain pelindung sasis IP65 (Tahan Air dan Debu). Namun kami sangat menghimbau untuk memastikan ujung kabel dan port di kendaraan Anda dalam keadaan kering sebelum mencolok.',
                  ),
                  _buildFaqItem(
                    'Bagaimana jika koneksi internet terputus?',
                    'Aplikasi pada perangkat Android Anda memerlukan koneksi internet yang aktif untuk mengirimkan instruksi mulai/berhenti serta menyelaraskan status relay secara real-time ke database cloud.',
                  ),

                  const SizedBox(height: 40),
                  _buildSectionTitle('Bantuan Darurat & Dukungan'),
                  _buildAlertCard(
                    Icons.warning_rounded,
                    'Kondisi Darurat',
                    'Jika ada asap atau kabel terkelupas dari mesin kami, tolong hindari menyentuhnya dan segera hubungi hotline darurat di: 0812-9862-8236',
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    context,
                    Icons.support_agent_rounded,
                    'Hubungi Support Tim',
                    'Waktu respon rata-rata: < 5 menit',
                    AppColors.secondary,
                    '081298628236',
                  ),
                  _buildContactCard(
                    context,
                    Icons.email_outlined,
                    'Email Layanan Pelanggan',
                    'Untuk pertanyaan umum & teknis',
                    AppColors.primary,
                    'syauqiakmal137@gmail.com',
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 20),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _buildStepCard(String number, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: AppColors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Row(
      children: [
        _categoryItem(Icons.account_balance_wallet_rounded, 'Dompet & Pay', AppColors.primaryContainer),
        const SizedBox(width: 12),
        _categoryItem(Icons.ev_station_rounded, 'Pengisian', AppColors.secondary),
        const SizedBox(width: 12),
        _categoryItem(Icons.security_rounded, 'Keamanan', AppColors.secondary),
      ],
    );
  }

  Widget _categoryItem(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.onSurfaceVariant,
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          expandedAlignment: Alignment.topLeft,
          children: [
            Text(
              answer,
              style: GoogleFonts.manrope(
                fontSize: 14,
                height: 1.7,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.error, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.error.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.content_copy_rounded, size: 20, color: AppColors.outlineVariant),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title berhasil disalin'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: color.withValues(alpha: 0.9),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
