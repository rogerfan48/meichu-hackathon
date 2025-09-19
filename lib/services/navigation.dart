import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:foodie/pages/main_page.dart';
import 'package:foodie/pages/home_page.dart';
import 'package:foodie/pages/flashcard/flashcard_page.dart';
import 'package:foodie/pages/screenReader/accessibility_page.dart';
import 'package:foodie/pages/history_page.dart';

final routerConfig = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainPage(child: child), // 傳入 tab page
      routes: [
        GoRoute(path: '/home', pageBuilder: (context, state) => const NoTransitionPage(child: HomePage())),
        GoRoute(path: '/flashcard', pageBuilder: (context, state) => const NoTransitionPage(child: FlashcardPage())),
        GoRoute(path: '/history', pageBuilder: (context, state) => const NoTransitionPage(child: HistoryPage())),
        GoRoute(path: '/accessibility', pageBuilder: (context, state) => NoTransitionPage(child: AccessibilityPage())),
      ],
    ),
  ],
  redirect: (context, state) {
    final currentPath = state.uri.path;
    if (currentPath == '/') return '/home';
    return null;
  },
  errorBuilder:
      (context, state) => Scaffold(body: Center(child: Text('Page not found: ${state.uri.path}'))),
);

class NavigationService {
  // late final GoRouter _router;

  // NavigationService() {
  //   _router = routerConfig;
  // }

  // String _currentPath(BuildContext context) {
  //   return GoRouterState.of(context).uri.path;
  // }
}
