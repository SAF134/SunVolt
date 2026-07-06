import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class SunVoltShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Color? baseColor;
  final Color? highlightColor;

  const SunVoltShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? AppColors.surfaceVariant.withValues(alpha: 0.6),
      highlightColor: highlightColor ?? AppColors.surfaceContainerLowest,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: shape == BoxShape.circle ? null : (borderRadius ?? BorderRadius.circular(12)),
          shape: shape,
        ),
      ),
    );
  }
}

class SunVoltHistorySkeleton extends StatelessWidget {
  const SunVoltHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const SunVoltShimmer(width: 48, height: 48, shape: BoxShape.circle),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SunVoltShimmer(width: 120, height: 16),
                  const SizedBox(height: 8),
                  const SunVoltShimmer(width: 80, height: 12),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SunVoltShimmer(width: 60, height: 16),
                const SizedBox(height: 8),
                const SunVoltShimmer(width: 40, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SunVoltWalletBalanceSkeleton extends StatelessWidget {
  const SunVoltWalletBalanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SunVoltShimmer(
              width: 150, 
              height: 14, 
              baseColor: Colors.white24, 
              highlightColor: Colors.white60
            ),
            SunVoltShimmer(
              width: 60, 
              height: 24, 
              borderRadius: BorderRadius.circular(999),
              baseColor: Colors.white24,
              highlightColor: Colors.white60,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const SunVoltShimmer(
              width: 32, 
              height: 32, 
              shape: BoxShape.circle,
              baseColor: Colors.white24,
              highlightColor: Colors.white60,
            ),
            const SizedBox(width: 12),
            const SunVoltShimmer(
              width: 180, 
              height: 40,
              baseColor: Colors.white24,
              highlightColor: Colors.white60,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SunVoltShimmer(
              width: 16, 
              height: 16, 
              shape: BoxShape.circle,
              baseColor: Colors.white24,
              highlightColor: Colors.white60,
            ),
            const SizedBox(width: 4),
            const SunVoltShimmer(
              width: 120, 
              height: 18,
              baseColor: Colors.white24,
              highlightColor: Colors.white60,
            ),
          ],
        ),
      ],
    );
  }
}

class SunVoltProfileSkeleton extends StatelessWidget {
  const SunVoltProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        // Avatar circle shimmer
        const SunVoltShimmer(
          width: 100,
          height: 100,
          shape: BoxShape.circle,
        ),
        const SizedBox(height: 16),
        // Name shimmer
        const SunVoltShimmer(
          width: 180,
          height: 24,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        const SizedBox(height: 8),
        // Email shimmer
        const SunVoltShimmer(
          width: 220,
          height: 14,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        const SizedBox(height: 16),
        // Role badge shimmer
        const SunVoltShimmer(
          width: 100,
          height: 28,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ],
    );
  }
}

class SunVoltChargingStatusSkeleton extends StatelessWidget {
  const SunVoltChargingStatusSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Status badge
          const SunVoltShimmer(
            width: 220,
            height: 28,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          const SizedBox(height: 32),
          // Energy orb circle
          const SunVoltShimmer(
            width: 280,
            height: 280,
            shape: BoxShape.circle,
          ),
          const SizedBox(height: 24),
          // Clean energy journey text
          const SunVoltShimmer(
            width: 240,
            height: 22,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          const SizedBox(height: 32),
          // Running tariff card container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SunVoltShimmer(width: 90, height: 14),
                      const SizedBox(height: 8),
                      const SunVoltShimmer(width: 160, height: 28),
                      const SizedBox(height: 8),
                      const SunVoltShimmer(width: 200, height: 12),
                    ],
                  ),
                ),
                const SunVoltShimmer(width: 40, height: 40, shape: BoxShape.circle),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Real-time power card container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SunVoltShimmer(width: 100, height: 14),
                      const SizedBox(height: 8),
                      const SunVoltShimmer(width: 140, height: 32),
                    ],
                  ),
                ),
                const SunVoltShimmer(width: 44, height: 44, shape: BoxShape.circle),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Swipe button skeleton
          const SunVoltShimmer(
            width: double.infinity,
            height: 64,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
