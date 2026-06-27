import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  double _loadingProgress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();

    // Animate loading bar
    _timer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (_loadingProgress >= 1.0) {
        timer.cancel();
        _checkAuthAndNavigate();
        return;
      }
      setState(() {
        _loadingProgress += 0.01;
      });
    });
  }

  void _checkAuthAndNavigate() async {
    final user = AuthService().currentUser;
    if (!mounted) return;
    
    if (user != null) {
      try {
        // Cek apakah ada sesi pengisian aktif untuk user ini di stasiun sekunder
        final FirebaseFirestore secondaryFirestore = FirebaseFirestore.instanceFor(app: Firebase.app('secondary'));
        final stationDoc = await secondaryFirestore.collection('stations').doc('station_01').get();
        
        if (mounted) {
          final data = stationDoc.data();
          if (data != null && 
              data['charging_user_uid'] == user.uid && 
              data['vehicle_type'] != null && 
              data['vehicle_type'].toString().isNotEmpty) {
            
            final String vehicleType = data['vehicle_type'] as String;
            Navigator.of(context).pushReplacementNamed(
              '/charging-status',
              arguments: vehicleType,
            );
            return;
          }
        }
      } catch (e) {
        debugPrint('Gagal memeriksa sesi aktif: $e');
      }
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/welcome');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Top-left yellow glow
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Bottom-right green glow
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Subtle Leaf decoration at bottom right
            Positioned(
              bottom: 40,
              right: 20,
              child: Transform.rotate(
                angle: -0.2,
                child: Icon(
                  Icons.eco_rounded,
                  size: 110,
                  color: AppColors.secondary.withValues(alpha: 0.08),
                ),
              ),
            ),
            
            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Concentric futuristic charging rings
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer ring
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.12),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Middle ring
                            Container(
                              width: 114,
                              height: 114,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.22),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Elevated central logo container
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Image.asset(
                                  'assets/images/Logo_SunVolt.png',
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            // Charging ticks
                            Positioned(
                              top: 4,
                              child: Container(
                                width: 4,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              child: Container(
                                width: 4,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 4,
                              child: Container(
                                width: 12,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 4,
                              child: Container(
                                width: 12,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Brand name
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sun',
                              style: TextStyle(color: AppColors.yellowAccent400),
                            ),
                            TextSpan(
                              text: 'Volt',
                              style: TextStyle(color: AppColors.voltGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom tagline & progress bar
            Positioned(
              bottom: 80,
              left: 48,
              right: 48,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Energi Surya untuk Perjalanan Anda',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Loading bar
                    Container(
                      height: 6,
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _loadingProgress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
