import 'package:flutter/material.dart';
import '../../core/widgets/sunvolt_bottom_nav.dart';
import '../home/home_screen.dart';
import '../history/history_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/profile_screen.dart';

import 'package:flutter/services.dart';
import '../../core/widgets/sunvolt_confirmation_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    WalletScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        SunVoltConfirmationDialog.show(
          context,
          title: 'Keluar Aplikasi',
          message: 'Apakah Anda yakin ingin keluar dari aplikasi SunVolt?',
          onConfirm: () {
            SystemNavigator.pop();
          },
        );
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: SunVoltBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
