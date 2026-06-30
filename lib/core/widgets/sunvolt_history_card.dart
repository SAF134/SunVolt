import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

class SunVoltHistoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String station;
  final String time;
  final String energy;
  final String cost;
  final String status;
  final bool isPositive;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onDelete;

  const SunVoltHistoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.station,
    required this.time,
    required this.energy,
    required this.cost,
    required this.status,
    this.isPositive = false,
    this.padding,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Warna dinamis berdasarkan tipe transaksi
    final Color accentColor = isPositive ? AppColors.secondary : AppColors.error;
    final Color accentBg = isPositive 
        ? AppColors.secondaryContainer.withValues(alpha: 0.2) 
        : AppColors.error.withValues(alpha: 0.1);

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.outlineVariant.withValues(alpha: 0.25),
              AppColors.outlineVariant.withValues(alpha: 0.08),
            ],
          ),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          padding: const EdgeInsets.all(18.5),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          station,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 16),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _detailCol(Icons.schedule, time, null),
                    _detailCol(Icons.bolt, energy, accentColor),
                    _detailCol(Icons.payments, cost, accentColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailCol(IconData icon, String text, Color? textColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: textColor ?? AppColors.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
