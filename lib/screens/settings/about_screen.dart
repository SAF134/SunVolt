import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SunVoltAppBar(
        showBackButton: true,
        title: 'Tentang Aplikasi',
        trailing: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Image.asset(
                'assets/images/Logo_SunVolt.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
                children: const [
                  TextSpan(
                    text: 'Sun',
                    style: TextStyle(color: AppColors.yellowAccent400),
                  ),
                  TextSpan(
                    text: 'Volt',
                    style: TextStyle(color: AppColors.voltGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versi 1.0.0 (Global Release)',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            // Description
            Text(
              'SunVolt adalah platform ekosistem pengisian daya kendaraan listrik revolusioner yang dirancang dengan estetika "Solar Kinetic". Kami menggabungkan teknologi pintar dengan pengalaman pengguna yang premium untuk mempercepat transisi energi hijau di Indonesia.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 15,
                height: 1.7,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Dengan fitur pengisian cerdas, integrasi pembayaran real-time, dan pemantauan energi yang presisi, SunVolt memberdayakan setiap pengguna untuk berkontribusi pada masa depan yang lebih bersih dan berkelanjutan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 15,
                height: 1.7,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 48),
            // Build Info
            _buildInfoRow('Dibuat dengan', 'Flutter v3.19.0'),
            _buildInfoRow('Lisensi', 'Apache License 2.0'),
            _buildInfoRow('Penerbit', 'SunVolt Green Tech'),
            _buildInfoRow('Kontak', '081298628236'),
            const SizedBox(height: 64),
            // Copyright
            Text(
              '© 2026 SunVolt Indonesia.\nSeluruh hak cipta dilindungi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
