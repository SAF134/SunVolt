import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';
import '../../core/widgets/sunvolt_history_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SunVoltAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Riwayat Aktivitas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 25, fontWeight: FontWeight.w800,
                        height: 1.1, letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 24),
                  // Section header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Hari Ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SunVoltHistoryCard(icon: Icons.moped, title: 'Motor Listrik', station: 'Stasiun SunVolt', time: '14:30 - 15:45', energy: '3 kWh', cost: 'Rp 7.500', status: 'Selesai'),
                  const SunVoltHistoryCard(icon: Icons.pedal_bike, title: 'Sepeda Listrik', station: 'Stasiun SunVolt', time: '08:15 - 09:20', energy: '2 kWh', cost: 'Rp 5.000', status: 'Selesai'),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Kemarin',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SunVoltHistoryCard(icon: Icons.moped, title: 'Motor Listrik', station: 'Stasiun SunVolt', time: '16:00 - 17:30', energy: '4 kWh', cost: 'Rp 10.000', status: 'Selesai'),
                  const SunVoltHistoryCard(icon: Icons.pedal_bike, title: 'Sepeda Listrik', station: 'Stasiun SunVolt', time: '09:45 - 10:30', energy: '2 kWh', cost: 'Rp 5.000', status: 'Selesai'),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '28 Maret 2026',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SunVoltHistoryCard(icon: Icons.moped, title: 'Motor Listrik', station: 'Stasiun SunVolt', time: '11:00 - 12:15', energy: '3 kWh', cost: 'Rp 7.500', status: 'Selesai'),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
