import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodie/pages/loading_page.dart';
import 'package:go_router/go_router.dart';
import 'package:foodie/pages/main_page.dart';
import 'package:foodie/pages/home_page.dart';
import 'package:foodie/pages/flashcard/flashcard_page.dart';
import 'package:foodie/pages/flashcard/flashcard_practice_page.dart';
import 'package:foodie/pages/screenReader/accessibility_page.dart';
import 'package:foodie/pages/upload_page.dart';
import 'package:foodie/pages/flashcard_page.dart';
import 'package:foodie/pages/setting_page.dart';
import 'package:foodie/pages/history_page.dart';

final routerConfig = GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/loading',
      pageBuilder: (context, state) => NoTransitionPage(child: const LoadingPage()),
    ),
    ShellRoute(
      builder: (context, state, child) => MainPage(child: child), // 傳入 tab page
      routes: [
        GoRoute(
          path: '/upload',
          pageBuilder: (context, state) => const NoTransitionPage(child: UploadPage()),
        ),
        GoRoute(
          path: '/flashcard',
          pageBuilder: (context, state) => const NoTransitionPage(child: FlashcardPage()),
          routes: [
            GoRoute(
              path: '/practice',
              pageBuilder: (context, state) => const NoTransitionPage(child: FlashcardPracticePage()),
            ),
          ],
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => const NoTransitionPage(child: HistoryPage()),
        ),
        GoRoute(
          path: '/setting',
          pageBuilder: (context, state) => NoTransitionPage(child: SettingPage()),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final currentPath = state.uri.path;
    if (currentPath == '/') return '/upload';
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
