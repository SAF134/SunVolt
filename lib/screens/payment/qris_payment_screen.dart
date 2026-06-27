import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_confirmation_dialog.dart';

class QrisPaymentScreen extends StatefulWidget {
  const QrisPaymentScreen({super.key});

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  bool _isLoading = false;
  String? _redirectUrl;

  // Gunakan Ngrok URL agar aplikasi di HP fisik bisa mengakses server backend lokal PC Anda.
  // Jika Ngrok di-restart, URL ini juga harus di-update.
  final String _baseUrl = 'https://sunvolt-backend.vercel.app';

  Future<void> _createTransaction(String amountStr) async {
    setState(() => _isLoading = true);

    try {
      // Hilangkan 'Rp ' dan '.' untuk mendapatkan angka murni
      final int amount = int.parse(amountStr.replaceAll(RegExp(r'[^0-9]'), ''));
      final user = FirebaseAuth.instance.currentUser;
      final String orderId = 'SV-${DateTime.now().millisecondsSinceEpoch}';

      final response = await http.post(
        Uri.parse('$_baseUrl/api/create-transaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'orderId': orderId,
          'customerName': user?.displayName ?? 'User SunVolt',
          'customerEmail': user?.email ?? 'test@sunvolt.com',
          'userId': user?.uid ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _redirectUrl = data['redirect_url'];
        
        if (_redirectUrl != null) {
          // Gunakan mode externalApplication agar link tidak dibuka di WebView kecil
          // tapi langsung di Chrome/Browser HP yang lebih stabil.
          final Uri url = Uri.parse(_redirectUrl!);
          
          await launchUrl(
            url, 
            mode: LaunchMode.externalApplication,
          );

          // Beri jeda 1 detik agar browser punya waktu untuk loading sebelum kita tutup halamannya
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menuju halaman pembayaran...'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Kembali ke WalletScreen
          }
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal membuat transaksi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String amount =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Rp 10.000';

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          // Background Glow Blurs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 24, 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppColors.onSurface,
                        iconSize: 20,
                        onPressed: () {
                          SunVoltConfirmationDialog.show(
                            context,
                            title: 'Konfirmasi Pembatalan',
                            message: 'Apakah Anda yakin ingin membatalkan transaksi ini?',
                            isDestructive: true,
                            onConfirm: () => Navigator.pop(context),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/images/Logo_SunVolt.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 6),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
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
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Pembayaran Sanbox Midtrans',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Klik tombol di bawah untuk mendapatkan Sanbox Midtrans',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Total Bill Card - Dark Slate Premium design
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFFD700).withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(1.5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 26.5, horizontal: 22.5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1E293B),
                                  Color(0xFF0F172A),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(26.5),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'TOTAL TAGIHAN',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.0,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  amount,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFFFD700),
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        // QR Code Container (Mock Sanbox Midtrans scanner mockup)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.outlineVariant.withValues(alpha: 0.15),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Mock QR scanner box
                              Container(
                                width: 130,
                                height: 130,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.qr_code_2_rounded,
                                  size: 106,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Sistem siap melakukan pembayaran secara aman melalui Sandbox Midtrans',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        // Info Note
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.primaryContainer.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.primaryContainer,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tombol bayar di bawah ini akan membuka halaman pembayaran Sandbox Midtrans resmi.',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    color: AppColors.onSurfaceVariant,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: _isLoading
                ? const SizedBox(
                    height: 58,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                : Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: SizedBox(
                          height: 58,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              SunVoltConfirmationDialog.show(
                                context,
                                title: 'Konfirmasi Pembatalan',
                                message: 'Apakah Anda yakin ingin membatalkan transaksi ini?',
                                isDestructive: true,
                                onConfirm: () => Navigator.pop(context),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.error.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              foregroundColor: AppColors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(Icons.close_rounded, size: 20),
                            label: Text(
                              'Batalkan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Pay Button
                      Expanded(
                        child: Container(
                          height: 58,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFF176),
                                Color(0xFFF5C400),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(1.5),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.5),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFD700),
                                  Color(0xFFE5B200),
                                ],
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  SunVoltConfirmationDialog.show(
                                    context,
                                    title: 'Konfirmasi Pembayaran',
                                    message: 'Anda akan dialihkan ke halaman pembayaran Midtrans untuk nominal $amount.',
                                    confirmLabel: 'Ya',
                                    cancelLabel: 'Tidak',
                                    onConfirm: () => _createTransaction(amount),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16.5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.payment_rounded,
                                      color: Color(0xFF221B00),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Bayar',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF221B00),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
