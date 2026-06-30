import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';

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
                color: AppColors.primary.withValues(alpha: 0.08),
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
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Pembayaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
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
                          'Pembayaran Sandbox Midtrans',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Geser tombol di bawah untuk mendapatkan Sandbox Midtrans',
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
                                AppColors.primary.withValues(alpha: 0.3),
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
                                  AppColors.onSurface,
                                  AppColors.onSurface,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(26.5),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'TOTAL TAGIHAN',
                                  style: GoogleFonts.plusJakartaSans(
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
                                    color: AppColors.primary,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        // QR Code Container (Mock Sandbox Midtrans scanner mockup)
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
                                  color: AppColors.onSurface,
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
                                  'Geser tombol di bawah ini akan membuka halaman pembayaran Sandbox Midtrans resmi.',
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
                : SwipeToConfirmButton(
                    onConfirm: () => _createTransaction(amount),
                    text: 'Geser untuk Membayar',
                  ),
          ),
        ),
      ),
    );
  }
}

class SwipeToConfirmButton extends StatefulWidget {
  final VoidCallback onConfirm;
  final String text;
  final Color backgroundColor;
  final List<Color> activeGradient;

  const SwipeToConfirmButton({
    super.key,
    required this.onConfirm,
    required this.text,
    this.backgroundColor = AppColors.surfaceContainerLow,
    this.activeGradient = const [
      AppColors.primary,
      AppColors.yellowDark,
    ],
  });

  @override
  State<SwipeToConfirmButton> createState() => _SwipeToConfirmButtonState();
}

class _SwipeToConfirmButtonState extends State<SwipeToConfirmButton>
    with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDragDistance = constraints.maxWidth - 56.0 - 8.0;

        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: 56 + _dragValue * maxDragDistance,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.activeGradient,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              Center(
                child: Opacity(
                  opacity: (1 - _dragValue).clamp(0.0, 1.0),
                  child: Text(
                    widget.text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _dragValue * maxDragDistance,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragValue += details.primaryDelta! / maxDragDistance;
                      _dragValue = _dragValue.clamp(0.0, 1.0);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragValue > 0.85) {
                      setState(() {
                        _dragValue = 1.0;
                      });
                      widget.onConfirm();
                    } else {
                      final Animation<double> animation = Tween<double>(
                        begin: _dragValue,
                        end: 0.0,
                      ).animate(
                        CurvedAnimation(
                          parent: _animController,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                      animation.addListener(() {
                        setState(() {
                          _dragValue = animation.value;
                        });
                      });

                      _animController.reset();
                      _animController.forward();
                    }
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.onPrimaryFixed,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
