import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';
import '../../core/widgets/sunvolt_confirmation_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StationDetailScreen extends StatefulWidget {
  const StationDetailScreen({super.key});

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  int _selectedVehicle = 1; // 0 = sepeda, 1 = motor
  final _currencyFormat = NumberFormat.currency(
    locale: 'id', symbol: '', decimalDigits: 0,
  );

  late final FirebaseFirestore _secondaryFirestore;
  StreamSubscription? _stationSubscription;
  String _relayDCState = 'OFF';
  String _relayACState = 'OFF';
  String _vehicleType = '';

  @override
  void initState() {
    super.initState();
    _secondaryFirestore = FirebaseFirestore.instanceFor(app: Firebase.app('secondary'));
    _stationSubscription = _secondaryFirestore
        .collection('stations')
        .doc('station_01')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          setState(() {
            _relayDCState = data['relayDCState'] as String? ?? 'OFF';
            _relayACState = data['relayACState'] as String? ?? 'OFF';
            _vehicleType = data['vehicle_type'] as String? ?? '';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _stationSubscription?.cancel();
    super.dispose();
  }


  // ─── Spesifikasi Kendaraan ───
  // Biaya pengisian minimal 15% → 100% (85%)
  static const int _bikeFullCost = 2400;
  static const int _motorFullCost = 5400;

  int get _selectedMinBalance =>
      _selectedVehicle == 1 ? _motorFullCost : _bikeFullCost;
  String get _selectedVehicleName =>
      _selectedVehicle == 1 ? 'Motor Listrik' : 'Sepeda Listrik';

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
                  // ── Hero Image ──
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Informasi Tarif ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.04),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: Color(0xFFD4AF37),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TARIF PENGISIAN LISTRIK',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      'Rp 2.500',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    Text(
                                      ' / kWh',
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Pilih Kendaraan ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Pilih Kendaraan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          subtitle: 'Output Maksimal: 72V',
                        ),
                      ],
                    ),
                  ),
                             SizedBox(height: 100 + MediaQuery.paddingOf(context).bottom),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom CTA
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  // Cek apakah relay aktif dan slot sedang dipakai
                  if (_selectedVehicle == 0) {
                    if (_relayDCState != 'ON') {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Relay DC tidak aktif. Pengisian daya tidak dapat dimulai.',
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
                      return;
                    }
                    if (_vehicleType == 'bike') {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.block_rounded, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Slot sepeda listrik sedang terpakai oleh pengguna lain.',
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
                      return;
                    }
                  }

                  if (_selectedVehicle == 1) {
                    if (_relayACState != 'ON') {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Relay AC tidak aktif. Pengisian daya tidak dapat dimulai.',
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
                      return;
                    }
                    if (_vehicleType == 'motor') {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.block_rounded, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Slot motor listrik sedang terpakai oleh pengguna lain.',
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
                      return;
                    }
                  }
 
                  // Ambil saldo terbaru dari Firestore
                  final userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get();
                  final int currentBalance = userDoc.data()?['balance'] ?? 0;
                  final int minBalance = _selectedMinBalance;
                  final String vehicleName = _selectedVehicleName;
 
                  if (currentBalance < minBalance) {
                    if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Saldo Anda Rp ${_currencyFormat.format(currentBalance).trim()} tidak mencukupi! Minimal Rp ${_currencyFormat.format(minBalance).trim()} untuk $vehicleName.',
                                  style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(24),
                        ),
                      );
                    return;
                  }
 
                  if (!context.mounted) return;
                  SunVoltConfirmationDialog.show(
                    context,
                      title: 'Konfirmasi Pengisian',
                      message: 'Mulai mengisi daya $vehicleName?',
                      onConfirm: () => Navigator.pushNamed(
                        context,
                        '/charging-status',
                        arguments: _selectedVehicle == 1 ? 'motor' : 'bike',
                      ),
                    );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                  elevation: 4,
                  shadowColor:
                      const Color(0xFFEAB308).withValues(alpha: 0.2),
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
        ),
      ),
    );
  }

  // ─── Helper Widgets ───

  Widget _vehicleOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedVehicle == index;

    // Tentukan status slot secara real-time
    String statusText;
    Color statusColor;
    Color statusBgColor;
    if (index == 0) {
      if (_relayDCState != 'ON') {
        statusText = 'Relay Tidak Aktif';
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withValues(alpha: 0.08);
      } else if (_vehicleType == 'bike') {
        statusText = 'Sedang Dipakai';
        statusColor = AppColors.error;
        statusBgColor = AppColors.error.withValues(alpha: 0.08);
      } else {
        statusText = 'Tersedia';
        statusColor = AppColors.natureGreen;
        statusBgColor = AppColors.natureGreen.withValues(alpha: 0.08);
      }
    } else {
      if (_relayACState != 'ON') {
        statusText = 'Relay Tidak Aktif';
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withValues(alpha: 0.08);
      } else if (_vehicleType == 'motor') {
        statusText = 'Sedang Dipakai';
        statusColor = AppColors.error;
        statusBgColor = AppColors.error.withValues(alpha: 0.08);
      } else {
        statusText = 'Tersedia';
        statusColor = AppColors.natureGreen;
        statusBgColor = AppColors.natureGreen.withValues(alpha: 0.08);
      }
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFFFD700).withValues(alpha: 0.04) 
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD700)
                : Colors.black.withValues(alpha: 0.05),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFFFD700).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? const Color(0xFF221B00)
                    : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            
            // Text Column
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Status Pill Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Radio button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFFD700)
                      : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
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
