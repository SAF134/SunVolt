import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (mounted && user != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Google gagal: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/Logo_SunVolt.png',
                        width: 42,
                        height: 42,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 4),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
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
                  const SizedBox(height: 32),
                  // Headline
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: AppColors.onBackground,
                      ),
                      children: [
                        const TextSpan(text: 'Selamat Datang di '),
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
                  const SizedBox(height: 16),
                  Text(
                    'Nyalakan masa depan Anda dengan energi bersih dan berkelanjutan.',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Illustration
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBZVFAkLwMArvfyzQtsgLdHmVAJ2aKb7v2KuH7uxkkqz6UjxmxOBcvxa-iHBVFMESpz9XNqTMVJiLfaN58r8aeKzAGBWDxMIlFFwYvCe5psNAsUIuRMcVtOqDo2K2YMD3NcB3e_bqs6mRbAoLkHyBnJ0e9kX4Xm7wStC570991cUoLOVZivl_A_DcWiU0UXrCU4DKPgS_NfwL6SzQlCrV-OtwcLQocVB5br38_cgwh-N6IWcrXw1fGZRkZobJO2NAXVHWVfQZME9Jc',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.surfaceContainerHigh,
                            child: const Center(
                              child: Icon(
                                Icons.solar_power,
                                size: 80,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Glassmorphism badge
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(
                                Icons.eco,
                                color: AppColors.onPrimaryContainer,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Energi Terbarukan',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onBackground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '100% Ramah Lingkungan',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Google Sign-In Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(
                          color: AppColors.primaryContainer,
                        ),
                        backgroundColor: AppColors.primaryContainer,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google.png',
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.g_mobiledata, size: 30),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Masuk dengan Akun Google',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ToS
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Dengan melanjutkan, Anda menyetujui ',
                        ),
                        TextSpan(
                          text: 'Ketentuan Layanan',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
