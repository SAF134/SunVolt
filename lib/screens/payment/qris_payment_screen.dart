import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_confirmation_dialog.dart';

class QrisPaymentScreen extends StatelessWidget {
  const QrisPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String amount =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Rp 10.000';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Yellow gradient top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryContainer.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/Logo_SunVolt.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 4),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
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
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          amount,
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Pindai untuk Membayar',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28, fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gunakan aplikasi pembayaran pilihan Anda',
                          style: GoogleFonts.manrope(
                            fontSize: 14, color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Total Bill Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Total Tagihan',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  color: AppColors.onPrimaryContainer.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                amount,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.onPrimaryContainer,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // QR placeholder section
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'QRIS DINAMIS',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12, fontWeight: FontWeight.w800,
                                    color: AppColors.primary, letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // QR Code card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    // QR placeholder
                                    Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.06),
                                            blurRadius: 16,
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // QR grid pattern
                                          GridView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.all(24),
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 10,
                                              mainAxisSpacing: 2,
                                              crossAxisSpacing: 2,
                                            ),
                                            itemCount: 100,
                                            itemBuilder: (context, index) {
                                              final random = (index * 7 + 3) % 3;
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: random == 0
                                                      ? Colors.black87
                                                      : random == 1
                                                          ? Colors.black54
                                                          : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(1),
                                                ),
                                              );
                                            },
                                          ),
                                          // Center logo
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.bolt, color: AppColors.primaryContainer, size: 24),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'NMID: ID1020034857211',
                                      style: GoogleFonts.manrope(
                                        fontSize: 12, fontWeight: FontWeight.w500,
                                        color: AppColors.onSurfaceVariant, letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: 'SUN',
                                            style: TextStyle(color: AppColors.yellowAccent400),
                                          ),
                                          TextSpan(
                                            text: 'VOLT',
                                            style: TextStyle(color: AppColors.voltGreen),
                                          ),
                                          TextSpan(
                                            text: ' INDONESIA ENERGY',
                                            style: TextStyle(color: AppColors.onSurface),
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
                        const SizedBox(height: 24),
                        // Timer
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.errorContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer, color: AppColors.error, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '04:59',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20, fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Payment info cards
                        Row(
                          children: const [
                            Expanded(child: PaymentInfoCard(icon: Icons.qr_code_scanner, label: 'Metode', value: 'QRIS')),
                            SizedBox(width: 12),
                            Expanded(child: PaymentInfoCard(icon: Icons.timer_outlined, label: 'Batas Waktu', value: '5 Menit')),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Info note
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info, color: AppColors.tertiary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Pastikan nominal pembayaran sesuai dengan tagihan. Status pembayaran akan diperbarui secara otomatis.',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Sudah Bayar button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              SunVoltConfirmationDialog.show(
                                context,
                                title: 'Sudah Bayar?',
                                message: 'Pastikan Anda telah menyelesaikan pembayaran pada aplikasi E-Wallet Anda.',
                                onConfirm: () {
                                  Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: AppColors.onPrimaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle),
                            label: Text(
                              'Sudah Bayar',
                              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Cancel
                        Center(
                          child: TextButton(
                            onPressed: () {
                              SunVoltConfirmationDialog.show(
                                context,
                                title: 'Batalkan Transaksi?',
                                message: 'Apakah Anda yakin ingin membatalkan transaksi pengisian saldo ini?',
                                isDestructive: true,
                                onConfirm: () => Navigator.pop(context),
                              );
                            },
                            child: Text(
                              'Batalkan Transaksi',
                              style: GoogleFonts.manrope(
                                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const PaymentInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
