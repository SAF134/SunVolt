import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';
import '../../core/widgets/sunvolt_shimmer.dart';
import '../payment/payment_success_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _selectedAmount = 'Rp 10.000';
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  StreamSubscription<DocumentSnapshot>? _balanceSubscription;
  int? _previousBalance;

  @override
  void initState() {
    super.initState();
    _ensureUserDocExists();
    _startBalanceListener();
  }

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    super.dispose();
  }

  void _startBalanceListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _balanceSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final currentBalance = data['balance'] ?? 0;

        if (_previousBalance != null && currentBalance > _previousBalance!) {
          final int addedAmount = currentBalance - _previousBalance!;
          
          // Hitung kWh (Asumsi Rp 2.500 = 1 kWh)
          // Jika Rp 1 = 0.0004 kWh
          final double energyValue = addedAmount / 2500;
          final String energyText = addedAmount == 1 ? '0.0004 kWh' : '${energyValue.toStringAsFixed(1)} kWh';

          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                amount: addedAmount,
                energy: energyText,
              ),
            ),
          );
        }
        
        _previousBalance = currentBalance;
      }
    });
  }

  /// Pastikan dokumen user ada di Firestore (fallback untuk user lama)
  Future<void> _ensureUserDocExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'balance': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _onSelect(String amount, String energy) {
    setState(() {
      _selectedAmount = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Gunakan Stream untuk update real-time
    final Stream<DocumentSnapshot> userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots();

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
                      'Dompet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Balance card with StreamBuilder
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: userStream,
                      builder: (context, snapshot) {
                        int balance = 0;
                        double energy = 0.0;

                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          balance = data['balance'] ?? 0;
                          // Estimasi energi (~Rp 2.500 per kWh)
                          energy = balance / 2500;
                        }

                        return Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                // Base dark emerald gradient background
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF0F2017), // Very dark emerald
                                        Color(0xFF042F1A), // Deep dark green
                                        Color(0xFF02170E), // Almost black green
                                      ],
                                    ),
                                  ),
                                ),
                                // Subtle geometric background pattern (concentric rings & diagonal lines)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: CardPatternPainter(),
                                  ),
                                ),
                                // Clean border overlay
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                // Content
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: snapshot.connectionState == ConnectionState.waiting
                                      ? const Center(
                                          child: SunVoltWalletBalanceSkeleton(),
                                        )
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Header Row: Card title & Active Chip
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'SUNVOLT PAY',
                                                      style: GoogleFonts.spaceGrotesk(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: 2.0,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Saldo Tersedia',
                                                      style: GoogleFonts.manrope(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w500,
                                                        letterSpacing: 0.5,
                                                        color: Colors.white.withValues(alpha: 0.5),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withValues(alpha: 0.06),
                                                    borderRadius: BorderRadius.circular(999),
                                                    border: Border.all(
                                                      color: Colors.white.withValues(alpha: 0.1),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration: const BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Color(0xFF22C55E), // Neon green dot
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Color(0xFF22C55E),
                                                              blurRadius: 6,
                                                              spreadRadius: 1,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        'Aktif',
                                                        style: GoogleFonts.manrope(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.white.withValues(alpha: 0.9),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Middle Row: Big Balance Display
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.baseline,
                                              textBaseline: TextBaseline.alphabetic,
                                              children: [
                                                Text(
                                                  'Rp',
                                                  style: GoogleFonts.spaceGrotesk(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white.withValues(alpha: 0.8),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      _currencyFormat.format(balance).replaceAll('Rp', '').trim(),
                                                      style: GoogleFonts.spaceGrotesk(
                                                        fontSize: 42,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white,
                                                        letterSpacing: -1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Footer Row: kWh Equivalent & User Cardholder info
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // Energy Equivalent Pill
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary.withValues(alpha: 0.08),
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(
                                                      color: AppColors.primary.withValues(alpha: 0.15),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.bolt_rounded,
                                                        color: AppColors.primary,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '~ ${energy.toStringAsFixed(2)} kWh',
                                                        style: GoogleFonts.spaceGrotesk(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w700,
                                                          color: AppColors.primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // User's name
                                                Text(
                                                  user?.displayName?.toUpperCase() ?? 'PENGGUNA SUNVOLT',
                                                  style: GoogleFonts.spaceGrotesk(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 1.0,
                                                    color: Colors.white.withValues(alpha: 0.6),
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
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Top-up options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top Up Dompet',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20, fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '',
                          style: GoogleFonts.manrope(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Top-up grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(child: TopUpOptionCard(amount: 'Rp 5.000', energy: '~2 kWh', isSelected: _selectedAmount == 'Rp 5.000', onTap: () => _onSelect('Rp 5.000', '~2 kWh'))),
                        const SizedBox(width: 12),
                        Expanded(child: TopUpOptionCard(amount: 'Rp 10.000', energy: '~4 kWh', isSelected: _selectedAmount == 'Rp 10.000', onTap: () => _onSelect('Rp 10.000', '~4 kWh'))),
                        const SizedBox(width: 12),
                        Expanded(child: TopUpOptionCard(amount: 'Rp 15.000', energy: '~6 kWh', isSelected: _selectedAmount == 'Rp 15.000', onTap: () => _onSelect('Rp 15.000', '~6 kWh'))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(child: TopUpOptionCard(amount: 'Rp 20.000', energy: '~8 kWh', isSelected: _selectedAmount == 'Rp 20.000', onTap: () => _onSelect('Rp 20.000', '~8 kWh'))),
                        const SizedBox(width: 12),
                        Expanded(child: TopUpOptionCard(amount: 'Rp 25.000', energy: '~10 kWh', isSelected: _selectedAmount == 'Rp 25.000', onTap: () => _onSelect('Rp 25.000', '~10 kWh'))),
                        const SizedBox(width: 12),
                        Expanded(child: TopUpOptionCard(amount: 'Rp 30.000', energy: '~12 kWh', isSelected: _selectedAmount == 'Rp 30.000', onTap: () => _onSelect('Rp 30.000', '~12 kWh'))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Top Up Now button (Moved here)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/qris-payment',
                            arguments: _selectedAmount,
                          );
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined),
                            const SizedBox(width: 8),
                            Text(
                              'Top Up Sekarang',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 100 + MediaQuery.paddingOf(context).bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}

class TopUpOptionCard extends StatelessWidget {
  final String amount;
  final String energy;
  final bool isSelected;
  final String? tag;
  final VoidCallback onTap;

  const TopUpOptionCard({
    super.key,
    required this.amount,
    required this.energy,
    required this.isSelected,
    this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderGradient = isSelected
        ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFF00B050)])
        : LinearGradient(colors: [
            AppColors.outlineVariant.withValues(alpha: 0.25),
            AppColors.outlineVariant.withValues(alpha: 0.08),
          ]);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: borderGradient,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryContainer.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14.5, horizontal: 6.5),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14.5),
          ),
          child: Column(
            children: [
              if (tag != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.5) : AppColors.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag!,
                    style: GoogleFonts.manrope(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: AppColors.onPrimaryContainer, letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  amount,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  energy,
                  style: GoogleFonts.manrope(
                    fontSize: 11, fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.onPrimaryContainer.withValues(alpha: 0.7) : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw some subtle concentric circles centered at top right
    final center = Offset(size.width * 0.9, size.height * 0.1);
    for (double radius = 40; radius < size.width; radius += 40) {
      canvas.drawCircle(center, radius, paint);
    }

    // Draw some fine diagonal background lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..strokeWidth = 1.0;
    for (double i = -size.height; i < size.width; i += 24) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
