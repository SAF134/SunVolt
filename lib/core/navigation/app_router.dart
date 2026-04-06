import 'package:flutter/material.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/welcome_screen.dart';
import '../../screens/auth/sign_in_screen.dart';
import '../../screens/auth/sign_up_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/main/main_screen.dart';
import '../../screens/station/station_detail_screen.dart';
import '../../screens/charging/charging_status_screen.dart';
import '../../screens/payment/qris_payment_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/settings/help_faq_screen.dart';
import '../../screens/settings/about_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(const SplashScreen(), settings);
      case '/welcome':
        return _buildRoute(const WelcomeScreen(), settings);
      case '/sign-in':
        return _buildRoute(const SignInScreen(), settings);
      case '/sign-up':
        return _buildRoute(const SignUpScreen(), settings);
      case '/otp-verification':
        final email = settings.arguments as String? ?? '';
        return _buildRoute(OtpVerificationScreen(email: email), settings);
      case '/forgot-password':
        return _buildRoute(const ForgotPasswordScreen(), settings);
      case '/main':
        return _buildRoute(const MainScreen(), settings);
      case '/station-detail':
        return _buildRoute(const StationDetailScreen(), settings);
      case '/charging-status':
        return _buildRoute(const ChargingStatusScreen(), settings);
      case '/qris-payment':
        return _buildRoute(const QrisPaymentScreen(), settings);
      case '/edit-profile':
        return _buildRoute(const EditProfileScreen(), settings);
      case '/help-faq':
        return _buildRoute(const HelpFaqScreen(), settings);
      case '/about':
        return _buildRoute(const AboutScreen(), settings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
