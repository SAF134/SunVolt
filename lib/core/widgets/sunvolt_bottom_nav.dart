import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SunVoltBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SunVoltBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
        _NavItem(icon: Icons.ev_station, label: 'Beranda'),
    _NavItem(icon: Icons.account_balance_wallet, label: 'Dompet'),
    _NavItem(icon: Icons.history, label: 'Riwayat'),
    _NavItem(icon: Icons.person, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(48),
          topRight: Radius.circular(48),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(48),
          topRight: Radius.circular(48),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            color: Colors.white.withValues(alpha: 0.7),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 24 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isActive = index == currentIndex;

                return GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isActive
                              ? const Color(0xFFFACC15)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color:
                              isActive
                                  ? const Color(0xFF18181B)
                                  : const Color(0xFF71717A),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color:
                                isActive
                                    ? const Color(0xFF18181B)
                                    : const Color(0xFF71717A),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
