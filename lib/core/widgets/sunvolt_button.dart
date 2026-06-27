import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Primary button — Sun Yellow (#FFD700)
class SunVoltPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? trailing;
  final double height;

  const SunVoltPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.trailing,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF59D),
            Color(0xFFEAB308),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEAB308).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: Material(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(14.5),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.5),
            child: Row(
              mainAxisAlignment:
                  trailing != null
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 12)],
                    Text(
                      text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary button — Nature Green (#006D3D)
class SunVoltSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? trailing;
  final double height;

  const SunVoltSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.trailing,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.3),
            AppColors.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: Material(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14.5),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.5),
            child: Row(
              mainAxisAlignment:
                  trailing != null
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSecondary,
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Danger / Error button (for "Berhenti Mengisi")
class SunVoltDangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;

  const SunVoltDangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Material(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        shadowColor: AppColors.error.withValues(alpha: 0.2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 12)],
              Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onError,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
