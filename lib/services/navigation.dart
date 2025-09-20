import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/loading_page.dart';
import '../pages/main_page.dart';
import '../pages/upload_page.dart';
import '../pages/flashcard_page.dart';
import '../pages/setting_page.dart';
import '../pages/history_page.dart';
import '../pages/session_detail_page.dart';

final routerConfig = GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/loading',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoadingPage(),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => MainPage(child: child),
      routes: [
        GoRoute(
          path: '/upload',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: UploadPage(),
          ),
        ),
        GoRoute(
          path: '/flashcard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FlashcardPage(),
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HistoryPage(),
          ),
          routes: [
            GoRoute(
              path: ':sessionId',
              builder: (context, state) {
                final sessionId = state.pathParameters['sessionId']!;
                return SessionDetailPage(sessionId: sessionId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/setting',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingPage(),
          ),
        ),
      ],
    ),
  ],
);