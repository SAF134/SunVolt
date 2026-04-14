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
                          'Pembayaran QRIS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28, fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Klik tombol di bawah untuk mendapatkan QRIS',
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
                        
                        // Action Section
                        Center(
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: AppColors.primary)
                            : Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.qr_code_2_rounded, size: 100, color: AppColors.onSurface),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Sistem siap membuat QRIS\nmelalui Midtrans Sandbox',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.manrope(
                                            fontSize: 14, color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        SunVoltConfirmationDialog.show(
                                          context,
                                          title: 'Konfirmasi Pembayaran',
                                          message: 'Anda akan dialihkan ke halaman pembayaran Midtrans untuk nominal $amount.',
                                          confirmLabel: 'Ya',
                                          cancelLabel: 'Tidak',
                                          onConfirm: () => _createTransaction(amount),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.onSurface,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.payment_rounded, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Bayar Sekarang',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16, fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        ),
                        
                        const SizedBox(height: 48),
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
                              const Icon(Icons.info_outline, color: AppColors.tertiary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tombol di atas akan membuka halaman pembayaran Midtrans. Silakan pilih metode QRIS dan simpan/scan kodenya.',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        // Cancel
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
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
                              side: const BorderSide(color: AppColors.error),
                              foregroundColor: AppColors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.close_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Batalkan Transaksi',
                                  style: GoogleFonts.manrope(
                                    fontSize: 16, fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
