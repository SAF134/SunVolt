import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sunvolt_text_field.dart';
import '../../core/widgets/sunvolt_confirmation_dialog.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // App bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Profil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Avatar with edit
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
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
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBWYaGPzV1ioI7Z4v_nqBN_xb9W5kZM6h_Mw_EvO7mM7DSVPKrNp250Ghe-3IHcJqIpKkfoxoIjxTrVEXIRVxlQCkMC1i1P1tLTGPRILhMeQMSxPjCbHYlL9h-xp8x8e6k-Z1pA4gzwAhKfg9kkJBNKCNzw6B7m01jYoKVKLZMv8V-BefZgqEjlwg14jixaWBL-MFu5SzY4Rrt1TlZvnumrv4U6WTmCMW8C7AyXFsZYfhH-C3LUVwHBJPbBwOXhnKbqBh-aU9hC8',
                            fit: BoxFit.cover,
                            errorBuilder: (_, e, s) => const Icon(
                              Icons.person,
                              size: 56,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Ubah Foto Profil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Form
                  const SunVoltTextField(
                    label: 'Nama Lengkap',
                    hintText: 'SAF',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  const SunVoltTextField(
                    label: 'Email',
                    hintText: 'saf@gmail.com',
                    enabled: false,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(Icons.mail_outline, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          'Email tidak dapat diubah demi keamanan akun Anda',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SunVoltConfirmationDialog.show(
                          context,
                          title: 'Simpan Perubahan?',
                          message: 'Apakah Anda yakin ingin menyimpan perubahan pada profil Anda?',
                          onConfirm: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profil berhasil disimpan!')),
                            );
                            Navigator.pop(context);
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
                      icon: const Icon(Icons.check),
                      label: Text(
                        'Simpan Perubahan',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
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
