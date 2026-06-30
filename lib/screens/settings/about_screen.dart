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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Logo with sophisticated shadow & animation-like feel
                  _buildPremiumLogo(),
                  
                  const SizedBox(height: 24),
                  
                  // App Name
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Sun',
                          style: TextStyle(color: AppColors.yellowAccent),
                        ),
                        TextSpan(
                          text: 'Volt',
                          style: TextStyle(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Mission Statement
                  _buildCard(
                    child: Column(
                      children: [
                        Text(
                          'Misi Masa Depan Hijau',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'SunVolt lahir dari ambisi untuk merevolusi ekosistem energi di Indonesia. Melalui bahasa desain "Solar Kinetic", kami menghadirkan harmoni antara efisiensi energi surya dan kecepatan mobilitas elektrik.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            height: 1.8,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tujuan kami bukan sekadar menyediakan stasiun pengisian, namun membentuk gaya hidup berkelanjutan dengan transparansi penuh untuk masa depan bumi yang jauh lebih bersih.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            height: 1.8,
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Key Features
                  _buildSectionTitle('Fitur Unggulan SunVolt'),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    icon: Icons.speed_rounded,
                    color: AppColors.secondary,
                    title: 'Adaptive Smart Charging (CC-CV)',
                    desc: 'Profil kelistrikan yang otomatis menyesuaikan daya (Arus/Tegangan) demi menjaga keawetan dan kesehatan baterai secara jangka panjang.',
                  ),
                  _buildFeatureCard(
                    icon: Icons.layers_rounded,
                    color: AppColors.primary,
                    title: 'Interactive Glassmorphic Panel',
                    desc: 'Lembar detail stasiun melayang berbasis Glassmorphism yang interaktif dengan gestur usap jari dan efek memantul (spring physics).',
                  ),
                  _buildFeatureCard(
                    icon: Icons.settings_backup_restore_rounded,
                    color: AppColors.secondary,
                    title: 'Background Session Keep-Alive',
                    desc: 'Pelacakan dan sinkronisasi sesi pengisian daya secara presisi saat aplikasi diminimalkan menggunakan WidgetsBindingObserver.',
                  ),
                  _buildFeatureCard(
                    icon: Icons.swipe_rounded,
                    color: AppColors.error,
                    title: 'Anti-Accidental Swipe Gestures',
                    desc: 'Metode kendali usap (swipe) untuk pembayaran dan penghentian sesi pengisian daya guna menghindari penekanan tombol yang tidak disengaja.',
                  ),

                  const SizedBox(height: 32),

                  // Tech Stack & Info
                  _buildSectionTitle('Sistem & Hardware'),
                  const SizedBox(height: 16),
                  _buildInfoCard([
                    _infoEntry('Software Stack', 'Flutter (Android SDK) & Node.js Vercel'),
                    _infoEntry('Cloud Database', 'Google Cloud Firestore Real-time'),
                    _infoEntry('Microcontroller', 'ESP32 Dev Module (IoT Relay)'),
                    _infoEntry('Sensor Kelistrikan', 'ACS712 (Real-time Current)'),
                    _infoEntry('Routing API', 'Open Source Routing Machine (OSRM)'),
                  ]),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Image.asset(
        'assets/images/Logo_SunVolt.png',
        fit: BoxFit.contain,
      ),
    );
  }



  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
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

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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

  Widget _buildInfoCard(List<Widget> entries) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: entries,
      ),
    );
  }

  Widget _infoEntry(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
