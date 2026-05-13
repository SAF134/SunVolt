import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class SunVoltSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Color? baseColor;
  final Color? highlightColor;

  const SunVoltSkeleton({
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
      baseColor: baseColor ?? AppColors.surfaceContainerHigh,
      highlightColor: highlightColor ?? AppColors.surfaceContainerHighest,
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
            const SunVoltSkeleton(width: 48, height: 48, shape: BoxShape.circle),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SunVoltSkeleton(width: 120, height: 16),
                  const SizedBox(height: 8),
                  const SunVoltSkeleton(width: 80, height: 12),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SunVoltSkeleton(width: 60, height: 16),
                const SizedBox(height: 8),
                const SunVoltSkeleton(width: 40, height: 12),
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
            const SunVoltSkeleton(
              width: 150, 
              height: 14, 
              baseColor: Colors.white24, 
              highlightColor: Colors.white60
            ),
            SunVoltSkeleton(
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
            const SunVoltSkeleton(
              width: 32, 
              height: 32, 
              shape: BoxShape.circle,
              baseColor: Colors.white24,
              highlightColor: Colors.white60,
            ),
            const SizedBox(width: 12),
            const SunVoltSkeleton(
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
            const SunVoltSkeleton(
              width: 16, 
              height: 16, 
              shape: BoxShape.circle,
              baseColor: Colors.white24,
              highlightColor: Colors.white60,
            ),
            const SizedBox(width: 4),
            const SunVoltSkeleton(
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
