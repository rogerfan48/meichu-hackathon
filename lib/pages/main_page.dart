import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:foodie/widgets/bottom_nav_bar.dart';

class MainPage extends StatelessWidget {
  final Widget child;
  const MainPage({super.key, required this.child});

  static final _tabs = [
    '/map',
    '/ai',
    '/account',
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int activeIndex = _tabs.indexWhere((path) => location.startsWith(path));
    if (activeIndex == -1) activeIndex = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: activeIndex,
        onTap: (idx) {
          if (idx != activeIndex) {
            context.go(_tabs[idx]);
          }
        },
      ),
    );
  }
}

