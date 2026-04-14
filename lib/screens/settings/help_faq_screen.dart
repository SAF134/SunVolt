import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SunVoltAppBar(
        showBackButton: true,
        title: 'Bantuan & FAQ',
        trailing: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 32),
            _buildSectionTitle('Pertanyaan Populer'),
            _buildFaqItem(
              'Bagaimana cara mengisi saldo?',
              'Anda dapat mengisi saldo melalui menu Dompet dan memilih metode pembayaran QRIS yang tersedia. Saldo akan bertambah secara otomatis setelah pembayaran berhasil.',
            ),
            _buildFaqItem(
              'Berapa tarif pengisian kendaraan?',
              'Tarif disesuaikan dengan jenis kendaraan: Sepeda Listrik (Rp 2.500 per 1.0 kWh) dan Motor Listrik (Rp 5.000 per 2.0 kWh).',
            ),
            _buildFaqItem(
              'Berapa saldo minimum untuk mengisi daya?',
              'Saldo minimum harus mencukupi sesuai kendaraan: Rp 2.500 untuk Sepeda Listrik dan Rp 5.000 untuk Motor Listrik.',
            ),
            _buildFaqItem(
              'Mengapa ada warna berbeda di riwayat?',
              'Warna hijau menandakan transaksi masuk atau Top-Up (+), sedangkan warna merah menandakan transaksi keluar untuk pengisian daya (-).',
            ),
            _buildFaqItem(
              'Apa itu SunVolt Smart Charging?',
              'Fitur pengisian cerdas yang mengoptimalkan waktu dan daya berdasarkan kebutuhan kendaraan Anda untuk efisiensi maksimal.',
            ),
            _buildFaqItem(
              'Dimana lokasi stasiun pengisian?',
              'Buka menu Peta di halaman utama untuk melihat daftar seluruh stasiun SunVolt di sekitar Anda.',
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Hubungi Kami'),
            _buildContactItem(
              Icons.message_outlined,
              'WhatsApp',
              '081298628236',
              const Color(0xFF25D366),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 16),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari bantuan...',
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
          hintStyle: GoogleFonts.manrope(
            fontSize: 14,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
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
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        childrenPadding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20,
        ),
        expandedAlignment: Alignment.topLeft,
        children: [
          Text(
            answer,
            style: GoogleFonts.manrope(
              fontSize: 14,
              height: 1.6,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.manrope(
            fontSize: 13,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
