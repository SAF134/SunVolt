import 'package:flutter/material.dart';
import 'app_colors.dart';

// ── Duration Constants ──
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration pageTransition = Duration(milliseconds: 300);
}

// ── Curve Constants ──
class AppCurves {
  AppCurves._();

  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve overshoot = Curves.easeOutBack;
  static const Curve decelerate = Curves.decelerate;
}

/// AnimatedPress - Efek tekan pada tombol/kartu
/// Membungkus child dengan scale-down animation & ripple glow painter
class AnimatedPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final double borderRadius;
  final Color? glowColor;

  const AnimatedPress({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.97,
    this.borderRadius = 16.0,
    this.glowColor,
  });

  @override
  State<AnimatedPress> createState() => _AnimatedPressState();
}

class _AnimatedPressState extends State<AnimatedPress>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  late AnimationController _rippleController;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.defaultCurve,
    ));

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color finalGlowColor = widget.glowColor ?? AppColors.primary.withValues(alpha: 0.35);

    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _tapPosition = details.localPosition;
        });
        _controller.forward();
        _rippleController.forward(from: 0.0);
      },
      onTapUp: (details) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: CustomPaint(
          foregroundPainter: _RippleGlowPainter(
            tapPosition: _tapPosition,
            progress: _rippleController,
            color: finalGlowColor,
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _RippleGlowPainter extends CustomPainter {
  final Offset? tapPosition;
  final Animation<double> progress;
  final Color color;
  final double borderRadius;

  _RippleGlowPainter({
    required this.tapPosition,
    required this.progress,
    required this.color,
    required this.borderRadius,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (tapPosition == null || progress.value == 0.0 || progress.value == 1.0) {
      return;
    }

    final double maxRadius = size.width * 1.2;
    final double currentRadius = maxRadius * progress.value;
    final double opacity = 1.0 - progress.value;

    final Paint paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: color.a * opacity),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: tapPosition!, radius: currentRadius));

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawCircle(tapPosition!, currentRadius, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RippleGlowPainter oldDelegate) {
    return oldDelegate.tapPosition != tapPosition ||
        oldDelegate.progress != progress ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// FadeSlideIn - Animasi masuk dengan fade + slide dari bawah
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.offsetY = 20.0,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.defaultCurve),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.offsetY),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.defaultCurve),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
