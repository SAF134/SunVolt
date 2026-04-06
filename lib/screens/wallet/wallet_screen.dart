import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_app_bar.dart';
import '../../core/widgets/sunvolt_transaction_item.dart';
import '../../core/widgets/sunvolt_confirmation_dialog.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _selectedAmount = 'Rp 1';

  void _onSelect(String amount, String energy) {
    setState(() {
      _selectedAmount = amount;
    });
  }

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
                  // Balance card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF006D3D),
                            Color(0xFF004D2B),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'SALDO TERSEDIA',
                                style: GoogleFonts.manrope(
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5, color: Colors.white70,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.verified, color: AppColors.primaryContainer, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Aktif',
                                      style: GoogleFonts.manrope(
                                        fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Rp ',
                                  style: GoogleFonts.manrope(
                                    fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70,
                                  ),
                                ),
                                TextSpan(
                                  text: '0',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.bolt, color: AppColors.primaryContainer, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '0 kWh Total Energi',
                                style: GoogleFonts.manrope(
                                  fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                        Expanded(child: TopUpOptionCard(amount: 'Rp 1', energy: '~1 kWh', isSelected: _selectedAmount == 'Rp 1', tag: 'PERCOBAAN', onTap: () => _onSelect('Rp 1', '~1 kWh'))),
                        const SizedBox(width: 12),
                        Expanded(child: TopUpOptionCard(amount: 'Rp 10.000', energy: '~4 kWh', isSelected: _selectedAmount == 'Rp 10.000', tag: 'POPULER', onTap: () => _onSelect('Rp 10.000', '~4 kWh'))),
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
                          SunVoltConfirmationDialog.show(
                            context,
                            title: 'Konfirmasi Top Up',
                            message: 'Apakah Anda yakin ingin melakukan pengisian saldo sebesar $_selectedAmount?',
                            onConfirm: () => Navigator.pushNamed(
                              context,
                              '/qris-payment',
                              arguments: _selectedAmount,
                            ),
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
                        child: Text(
                          'Top Up Sekarang',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Transaction history
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Transaksi',
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
                  const SunVoltTransactionItem(title: 'Isi Daya Motor', subtitle: 'Stasiun SunVolt', time: '2 jam yang lalu', amount: '-Rp 10.000', isPositive: false),
                  const SunVoltTransactionItem(title: 'Top-Up Saldo', subtitle: 'QRIS', time: '5 jam yang lalu', amount: '+Rp 10.000', isPositive: true),
                  const SunVoltTransactionItem(title: 'Isi Daya Sepeda', subtitle: 'Stasiun SunVolt', time: 'Kemarin, 14:20', amount: '-Rp 5.000', isPositive: false),
                  const SunVoltTransactionItem(title: 'Top-Up Saldo', subtitle: 'QRIS', time: '2 hari yang lalu', amount: '+Rp 5.000', isPositive: true),
                  const SizedBox(height: 40),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : null,
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
            Text(
              amount,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              energy,
              style: GoogleFonts.manrope(
                fontSize: 11, fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.onPrimaryContainer.withValues(alpha: 0.7) : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
