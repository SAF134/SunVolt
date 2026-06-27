import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class SunVoltStationCard extends StatelessWidget {
  final String name;
  final String address;
  final List<String> tags;
  final String? distanceString;
  final VoidCallback onSelect;
  final VoidCallback? onClose;

  const SunVoltStationCard({
    super.key,
    required this.name,
    required this.address,
    required this.tags,
    this.distanceString,
    required this.onSelect,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isMain = tags.contains('Utama');
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.04),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Premium Pill Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isMain 
                          ? const Color(0xFFFFD700).withValues(alpha: 0.12)
                          : AppColors.secondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isMain 
                            ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                            : AppColors.secondary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMain ? Icons.star_rounded : Icons.flash_on_rounded,
                          color: isMain ? const Color(0xFFD4AF37) : AppColors.secondary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isMain ? 'Stasiun Utama' : (tags.isNotEmpty ? tags.first : 'Stasiun'),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isMain ? const Color(0xFF8A6D00) : AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40), // space for close button
                ],
              ),
              const SizedBox(height: 16),
              
              // Station Info Row (Icon + Name/Address)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.ev_station_rounded,
                      color: AppColors.secondary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.outline,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Distance Badge / Area (if available)
              if (distanceString != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.route_rounded,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Jarak Anda ke Stasiun: $distanceString',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Select Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700), // brand yellow
                    foregroundColor: const Color(0xFF221B00), // Dark text for contrast
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.near_me_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Pilih Stasiun Ini',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (onClose != null)
          Positioned(
            top: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: Color(0xFF71717A),
                ),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),
            ),
          ),
      ],
    );
  }
}
