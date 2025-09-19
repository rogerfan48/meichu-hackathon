import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';
import 'package:foodie/repositories/user_repo.dart';
import 'package:foodie/services/storage_service.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:foodie/pages/restaurant_info_page.dart';
import 'package:foodie/pages/restaurant_menu_page.dart';
import 'package:foodie/pages/restaurant_reviews_page.dart';
import 'package:foodie/pages/main_page.dart';
import 'package:foodie/pages/ai_page.dart';
import 'package:foodie/pages/home_page.dart';
import 'package:foodie/pages/flashcard_page.dart';
import 'package:foodie/pages/account_page.dart';
import 'package:foodie/pages/restaurant_page.dart';
import 'package:foodie/pages/browsing_history_page.dart';
import 'package:foodie/pages/my_reviews_page.dart';
import 'package:foodie/pages/dish_detail_page.dart';
import 'package:foodie/pages/screenReader/accessibility_page.dart';

final routerConfig = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainPage(child: child), // 傳入 tab page
      routes: [
        GoRoute(path: '/home', pageBuilder: (context, state) => const NoTransitionPage(child: HomePage())),
        GoRoute(path: '/flashcard', pageBuilder: (context, state) => const NoTransitionPage(child: FlashcardPage())),
        GoRoute(path: '/ai', pageBuilder: (context, state) => NoTransitionPage(child: AccessibilityPage()),
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
