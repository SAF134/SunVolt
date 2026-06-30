import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

class SunVoltAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final Widget? trailing;
  final bool showLogo;
  final VoidCallback? onBackPressed;

  const SunVoltAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.trailing,
    this.showLogo = true,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        boxShadow: AppShadows.subtle,
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: _getBlurFilter(),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLeading(context),
                  trailing ?? const BalanceBadgeCompact(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (showBackButton && title != null) {
      return Row(
        children: [
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.onSurface,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      );
    }

    if (showLogo) {
      return Row(
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
                  style: TextStyle(color: AppColors.yellowAccent),
                ),
                TextSpan(
                  text: 'Volt',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  static ImageFilter _getBlurFilter() {
    return ImageFilter.blur(sigmaX: 20, sigmaY: 20);
  }
}

/// Saldo badge widget for app bar trailing
class SaldoBadge extends StatelessWidget {
  final bool showLabel;

  const SaldoBadge({
    super.key,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        String balanceText = 'Rp 0';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final balance = data['balance'] ?? 0;
          balanceText = 'Rp ${NumberFormat.decimalPattern('id-ID').format(balance)}';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLabel) ...[
                Text(
                  'SALDO',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary.withValues(alpha: 0.6),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.account_balance_wallet_rounded, color: AppColors.secondary, size: 16),
              const SizedBox(width: 4),
              Text(
                balanceText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Balance badge with bolt icon variant
class BalanceBadgeCompact extends StatelessWidget {
  const BalanceBadgeCompact({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        String balanceText = 'Rp 0';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final balance = data['balance'] ?? 0;
          balanceText = 'Rp ${NumberFormat.decimalPattern('id-ID').format(balance)}';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: AppColors.secondary, size: 16),
              const SizedBox(width: 4),
              Text(
                balanceText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
