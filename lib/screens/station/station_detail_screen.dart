import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';
import '../../core/widgets/sunvolt_confirmation_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StationDetailScreen extends StatefulWidget {
  const StationDetailScreen({super.key});

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  int _selectedVehicle = 1; // 0 = sepeda, 1 = motor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // App bar
          SunVoltAppBar(
            showBackButton: true,
            title: 'Detail Stasiun',
            trailing: const BalanceBadgeCompact(),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image
                  Container(
                    margin: const EdgeInsets.all(24),
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://bee.telkomuniversity.ac.id/wp-content/uploads/2024/11/DJI_0042-1024x576.webp',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                        // Station info
                        Positioned(
                          bottom: 24,
                          left: 24,
                          right: 24,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stasiun SunVolt',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Tersedia',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Vehicle selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pilih Kendaraan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Vehicle options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _vehicleOption(
                          index: 0,
                          icon: Icons.pedal_bike,
                          title: 'Sepeda Listrik',
                          subtitle: 'Output Maksimal: 48V',
                        ),
                        const SizedBox(height: 12),
                        _vehicleOption(
                          index: 1,
                          icon: Icons.moped,
                          title: 'Motor Listrik',
                          subtitle: 'Output Kompatibel: 60V / 72V',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom CTA
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              // Ambil saldo terbaru dari Firestore
              final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
              final int currentBalance = userDoc.data()?['balance'] ?? 0;
              final int minBalance = _selectedVehicle == 1 ? 5000 : 2500;
              final String vehicleName = _selectedVehicle == 1 ? 'Motor Listrik' : 'Sepeda Listrik';

              if (currentBalance < minBalance) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Saldo Anda Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(currentBalance).trim()} kurang! Minimal Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(minBalance).trim()} untuk $vehicleName.',
                              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(24),
                    ),
                  );
                }
                return;
              }

              if (mounted) {
                SunVoltConfirmationDialog.show(
                  context,
                  title: 'Konfirmasi Pengisian',
                  message: 'Apakah Anda yakin ingin mulai mengisi daya kendaraan Anda di stasiun ini?',
                  onConfirm: () => Navigator.pushNamed(
                    context, 
                    '/charging-status',
                    arguments: _selectedVehicle == 1 ? 'motor' : 'bike',
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
              elevation: 4,
              shadowColor: const Color(0xFFEAB308).withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.bolt, size: 24),
            label: Text(
              'Mulai Isi Daya',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _vehicleOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedVehicle == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFFEAB308).withValues(alpha: 0.05), blurRadius: 12)]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.manrope(fontSize: 14, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryContainer : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

}
