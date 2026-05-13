import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';
import '../../core/widgets/sunvolt_history_card.dart';
import '../../core/widgets/sunvolt_shimmer.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SunVoltAppBar(),
      body: Column(
        children: [
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
                      'Riwayat',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 25, fontWeight: FontWeight.w800,
                        height: 1.1, letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .collection('activity_history')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 10)));
                      }
                      
                      // Menampilkan Shimmer Skeleton Loading
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          children: List.generate(4, (index) => const SunVoltHistorySkeleton()),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text('Belum ada aktivitas pengisian daya', 
                              style: GoogleFonts.manrope(color: AppColors.onSurface.withValues(alpha: 0.4))),
                          ),
                        );
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final isTopUp = data['type'] == 'topup';
                          
                          // Hitung energi untuk top-up berdasarkan nominal (Rp 2.500 = 1 kWh)
                          String energyText;
                          if (isTopUp) {
                            final amountStr = (data['amount'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
                            final amountNum = int.tryParse(amountStr) ?? 0;
                            final kWh = (amountNum / 2500).toStringAsFixed(2);
                            energyText = '+$kWh kWh';
                          } else {
                            final rawEnergy = data['energy'] ?? '1.00 kWh';
                            energyText = rawEnergy.toString().startsWith('-') ? rawEnergy : '-$rawEnergy';
                          }

                          return SunVoltHistoryCard(
                            icon: isTopUp ? Icons.account_balance_wallet : (data['title']?.toString().contains('Motor') == true 
                                ? Icons.moped : Icons.pedal_bike),
                            title: data['title'] ?? 'Transaksi',
                            station: data['subtitle'] ?? (isTopUp ? 'Setoran QRIS' : 'Stasiun SunVolt'),
                            time: _formatRelativeTime(data['timestamp'] as Timestamp?),
                            energy: energyText,
                            cost: data['amount'] ?? 'Rp 0',
                            status: 'Selesai',
                            isPositive: isTopUp,
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelativeTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) {
      if (diff.inDays == 1) return 'Kemarin';
      return '${diff.inDays} hari yang lalu';
    }
    return DateFormat('dd MMM yyyy').format(date);
  }
}
