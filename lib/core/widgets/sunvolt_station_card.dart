import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class SunVoltStationCard extends StatelessWidget {
  final String name;
  final String address;
  final int slots;
  final List<String> tags;
  final String? distanceString;
  final VoidCallback onSelect;
  final VoidCallback? onClose;

  const SunVoltStationCard({
    super.key,
    required this.name,
    required this.address,
    required this.slots,
    required this.tags,
    this.distanceString,
    required this.onSelect,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tags
              if (tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 24), // Space for close button
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      final isFirst = tag == tags.first;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isFirst
                              ? AppColors.primaryContainer
                              : AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isFirst
                                ? AppColors.onPrimaryContainer
                                : AppColors.onSecondaryContainer,
                            letterSpacing: -0.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.ev_station,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$slots Slot Tersedia',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (distanceString != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.route_rounded, // Route icon
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      distanceString!,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              // Navigate button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimaryContainer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.directions, size: 20),
                  label: Text(
                    'Pilih Stasiun Ini',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (onClose != null)
          Positioned(
            top: 4,
            right: 4,
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
