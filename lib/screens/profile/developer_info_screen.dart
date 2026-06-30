import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';

class DeveloperInfoScreen extends StatelessWidget {
  const DeveloperInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data pengembang
    final List<Map<String, String>> developers = [
      {
        'name': 'Syauqi Akmal Fadhali',
        'major': 'S1 Teknik Komputer \'22',
        'faculty': 'Fakultas Teknik Elektro',
        'university': 'Universitas Telkom',
        'nim': '1103223237',
        'role': 'Mobile Developer',
        'instagram': '@saf.134',
        'whatsapp': '+62 812-9862-8236',
        'email': 'syauqiaf@student.telkomuniversity.ac.id',
        'image': 'assets/images/akmal.jpg',
      },
      {
        'name': 'Fattah Ahmad Rasyad',
        'major': 'S1 Teknik Komputer \'22',
        'faculty': 'Fakultas Teknik Elektro',
        'university': 'Universitas Telkom',
        'nim': '1103220215',
        'role': 'Hardware Developer',
        'instagram': '@fattah_ar15',
        'whatsapp': '+62 812-8073-2778',
        'email': 'fattahar@student.telkomuniversity.ac.id',
        'image': 'assets/images/fattah.jpg',
      },
      {
        'name': 'Rizky Januar Hardi',
        'major': 'S1 Teknik Komputer \'22',
        'faculty': 'Fakultas Teknik Elektro',
        'university': 'Universitas Telkom',
        'nim': '1103220166',
        'role': 'Embedded System Developer',
        'instagram': '@firecalm',
        'whatsapp': '+62 822-7985-1130',
        'email': 'rizkyjh@student.telkomuniversity.ac.id',
        'image': 'assets/images/rizky.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SunVoltAppBar(
        showBackButton: true,
        title: 'Tentang Pengembang',
        trailing: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: developers.map((dev) => _buildDeveloperCard(context, dev)).toList(),
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context, Map<String, String> dev) {
    return Container(
      margin: const EdgeInsets.only(bottom: 48),
      child: Column(
        children: [
          // Profile Photo with AboutScreen-style Shadow & Container
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                dev['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.primaryContainer,
                  child: const Icon(Icons.person, size: 80, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Name and Details
          Text(
            dev['name']!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dev['major']!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dev['nim']!,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${dev['faculty']} - ${dev['university']}',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Role Badge using AboutScreen-like tokens
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              dev['role']!,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.secondary  ,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Contact Card with AboutScreen container style
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildContactRow(context, Icons.camera_alt, 'Instagram', dev['instagram']!, Colors.pink),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1, thickness: 1),
                ),
                _buildContactRow(context, Icons.message, 'WhatsApp', dev['whatsapp']!, AppColors.secondary),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1, thickness: 1),
                ),
                _buildContactRow(context, Icons.email, 'Email', dev['email']!, AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label berhasil disalin'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.onSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          icon: const Icon(Icons.copy_all_rounded, color: AppColors.secondary, size: 20),
        ),
      ],
    );
  }
}
