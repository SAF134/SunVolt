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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row ──
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          station,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    const SizedBox(width: 6),
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
              const SizedBox(height: 14),

              // ── Responsive Simetris Detail Container ──
              LayoutBuilder(
                builder: (context, constraints) {
                  // Jika layar sangat sempit (<300px), gunakan layout 2 baris agar tetap rapi
                  if (constraints.maxWidth < 300) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  time,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _detailItem(
                                icon: Icons.bolt,
                                text: energy,
                                textColor: accentColor,
                                alignment: Alignment.centerLeft,
                              ),
                              _detailItem(
                                icon: Icons.payments,
                                text: cost,
                                textColor: accentColor,
                                alignment: Alignment.centerRight,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  // Layout 3 kolom simetris responsif (Time - Energy - Cost)
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Waktu (Kiri)
                        Expanded(
                          flex: 5,
                          child: _detailItem(
                            icon: Icons.schedule,
                            text: time,
                            textColor: null,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Energi (Tengah)
                        Expanded(
                          flex: 4,
                          child: _detailItem(
                            icon: Icons.bolt,
                            text: energy,
                            textColor: accentColor,
                            alignment: Alignment.center,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Biaya (Kanan)
                        Expanded(
                          flex: 4,
                          child: _detailItem(
                            icon: Icons.payments,
                            text: cost,
                            textColor: accentColor,
                            alignment: Alignment.centerRight,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem({
    required IconData icon,
    required String text,
    required Color? textColor,
    required Alignment alignment,
  }) {
    return Align(
      alignment: alignment,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor ?? AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
