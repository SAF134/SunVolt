import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_confirmation_dialog.dart';
import '../../core/widgets/sunvolt_app_bar.dart';
import '../../core/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'Pengguna';
    final String email = user?.email ?? '-';
    final String? photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SunVoltAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Avatar - show Google profile photo if available
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryContainer,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: photoUrl != null
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded) return child;
                                return AnimatedOpacity(
                                  opacity: frame == null ? 0 : 1,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  child: child,
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: AppColors.onPrimaryContainer.withValues(alpha: 0.3),
                                  ),
                                );
                              },
                              errorBuilder: (_, e, s) => const Icon(
                                Icons.person,
                                size: 48,
                                color: AppColors.onPrimaryContainer,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 48,
                              color: AppColors.onPrimaryContainer,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name from Google account
                  Text(
                    displayName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24, fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Email from Google account
                  Text(
                    email,
                    style: GoogleFonts.manrope(
                      fontSize: 14, color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (email == 'firecalm2@gmail.com' || 
                              email == 'syauqiakmal137@gmail.com' || 
                              email == 'fattaha.rasyad@gmail.com')
                          ? AppColors.secondary.withValues(alpha: 0.1)
                          : AppColors.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (email == 'firecalm2@gmail.com' || 
                                email == 'syauqiakmal137@gmail.com' || 
                                email == 'fattaha.rasyad@gmail.com')
                            ? AppColors.secondary.withValues(alpha: 0.2)
                            : AppColors.primaryContainer.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      (email == 'firecalm2@gmail.com' || 
                       email == 'syauqiakmal137@gmail.com' || 
                       email == 'fattaha.rasyad@gmail.com')
                          ? 'Pengembang'
                          : 'Pembeli',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: (email == 'firecalm2@gmail.com' || 
                                email == 'syauqiakmal137@gmail.com' || 
                                email == 'fattaha.rasyad@gmail.com')
                            ? AppColors.secondary
                            : AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Menu
                  ProfileMenuItem(icon: Icons.help_outline, title: 'Bantuan & FAQ', onTap: () {
                    Navigator.pushNamed(context, '/help-faq');
                  }),
                  ProfileMenuItem(icon: Icons.info_outline, title: 'Tentang Aplikasi', onTap: () {
                    Navigator.pushNamed(context, '/about');
                  }),
                  ProfileMenuItem(icon: Icons.code, title: 'Tentang Pengembang', onTap: () {
                    Navigator.pushNamed(context, '/developer-info');
                  }),
                   if (email == 'firecalm2@gmail.com' || 
                      email == 'syauqiakmal137@gmail.com' || 
                      email == 'fattaha.rasyad@gmail.com') ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        SunVoltConfirmationDialog.show(
                          context,
                          title: 'Konfirmasi Akses',
                          message: 'Anda akan dialihkan ke halaman Dashboard Admin di browser luar. Lanjutkan?',
                          confirmLabel: 'Ya',
                          cancelLabel: 'Tidak',
                          onConfirm: () async {
                            final Uri url = Uri.parse('https://sunvolt-admin.vercel.app');
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      label: Text(
                        'Halaman Dashboard',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ],
                  // Logout
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        SunVoltConfirmationDialog.show(
                          context,
                          title: 'Konfirmasi Keluar',
                          message: 'Apakah Anda yakin ingin keluar dari akun SunVolt Anda?',
                          isDestructive: true,
                          onConfirm: () async {
                            final authService = AuthService();
                            await authService.signOut();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context, '/welcome', (route) => false,
                              );
                            }
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'Keluar Akun',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16, fontWeight: FontWeight.w700,
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

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
