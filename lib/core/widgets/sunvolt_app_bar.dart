import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEAB308).withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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
                  ?trailing,
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
  final String amount;
  final bool showLabel;

  const SaldoBadge({
    super.key,
    this.amount = 'Rp 0',
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
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
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Balance badge with bolt icon variant
class BalanceBadgeCompact extends StatelessWidget {
  final String amount;

  const BalanceBadgeCompact({super.key, this.amount = 'Rp 0'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, color: Color(0xFFEAB308), size: 16),
          const SizedBox(width: 4),
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
