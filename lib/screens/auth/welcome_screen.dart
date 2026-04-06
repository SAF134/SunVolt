import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  // Masuk button
                  SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: Material(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/sign-in'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Masuk',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Daftar button
                  SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: Material(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/sign-up'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daftar',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSecondary,
                                ),
                              ),
                              Icon(
                                Icons.person_add,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ],
                          ),
                        ),
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
