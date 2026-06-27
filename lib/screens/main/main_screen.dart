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
        body: AnimatedIndexedStack(
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

class AnimatedIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const AnimatedIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<AnimatedIndexedStack> createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _oldIndex;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _oldIndex = widget.index;
    _currentIndex = widget.index;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != _currentIndex) {
      _oldIndex = _currentIndex;
      _currentIndex = widget.index;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        final bool isMovingRight = _currentIndex > _oldIndex;
        final double value = curvedAnimation.value;

        return Stack(
          children: List.generate(widget.children.length, (index) {
            if (index == _currentIndex) {
              final Offset slideInOffset = isMovingRight
                  ? Offset(1.0 - value, 0.0)
                  : Offset(-1.0 + value, 0.0);
              return FractionalTranslation(
                translation: slideInOffset,
                child: widget.children[index],
              );
            } else if (index == _oldIndex && !_controller.isCompleted) {
              final Offset slideOutOffset = isMovingRight
                  ? Offset(0.0 - value, 0.0)
                  : Offset(0.0 + value, 0.0);
              return FractionalTranslation(
                translation: slideOutOffset,
                child: widget.children[index],
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        );
      },
    );
  }
}
