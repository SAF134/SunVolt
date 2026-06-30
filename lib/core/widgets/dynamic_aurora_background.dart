import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DynamicAuroraBackground extends StatefulWidget {
  final Widget? child;

  const DynamicAuroraBackground({super.key, this.child});

  @override
  State<DynamicAuroraBackground> createState() => _DynamicAuroraBackgroundState();
}

class _DynamicAuroraBackgroundState extends State<DynamicAuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _pulse1;
  late Animation<double> _pulse2;
  late Animation<double> _pulse3;

  late Animation<Offset> _move1;
  late Animation<Offset> _move2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _pulse1 = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeInOut)),
    );

    _pulse2 = Tween<double>(begin: 1.1, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeInOut)),
    );

    _pulse3 = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeInOut)),
    );

    _move1 = Tween<Offset>(
      begin: const Offset(-40, -40),
      end: const Offset(40, 20),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _move2 = Tween<Offset>(
      begin: const Offset(50, 80),
      end: const Offset(-30, -20),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background canvas
        Container(color: Colors.white),

        // Animated blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                // Blob 1: Sun Yellow (Left side)
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.1 + _move1.value.dx,
                  top: MediaQuery.of(context).size.height * 0.2 + _move1.value.dy,
                  child: Transform.scale(
                    scale: _pulse1.value,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Blob 2: Nature Green (Right side)
                Positioned(
                  right: MediaQuery.of(context).size.width * 0.1 + _move2.value.dx,
                  bottom: MediaQuery.of(context).size.height * 0.15 + _move2.value.dy,
                  child: Transform.scale(
                    scale: _pulse2.value,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Blob 3: Solar Gold (Center/Top Right)
                Positioned(
                  right: MediaQuery.of(context).size.width * 0.2 + _move1.value.dy,
                  top: MediaQuery.of(context).size.height * 0.1 + _move2.value.dx * 0.5,
                  child: Transform.scale(
                    scale: _pulse3.value,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.yellowAccent.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Blur Filter to turn blobs into smooth glowing aurora
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: const SizedBox.shrink(),
          ),
        ),

        // Foreground content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}
