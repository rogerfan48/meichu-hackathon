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
import 'package:foodie/pages/loading_page.dart';
import 'package:foodie/pages/main_page.dart';
import 'package:foodie/pages/map_page.dart';
import 'package:foodie/pages/ai_page.dart';
import 'package:foodie/pages/account_page.dart';
import 'package:foodie/pages/restaurant_page.dart';
import 'package:foodie/pages/browsing_history_page.dart';
import 'package:foodie/pages/my_reviews_page.dart';
import 'package:foodie/pages/dish_detail_page.dart';

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
          path: '/map',
          pageBuilder: (context, state) => NoTransitionPage(child: MapPage()),
          routes: [
            ShellRoute(
              pageBuilder: (context, state, child) {
                final restaurantId = state.pathParameters['id']!;
                return CustomTransitionPage(
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 0.7);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                  child: ChangeNotifierProvider(
                    create:
                        (context) => RestaurantDetailViewModel(
                          restaurantId: restaurantId,
                          restaurantRepository: context.read<RestaurantRepository>(),
                          reviewRepository: context.read<ReviewRepository>(),
                          userRepository: context.read<UserRepository>(),
                          storageService: context.read<StorageService>(),
                        ),
                    // RestaurantPage 是 consumer，也是外殼
                    child: RestaurantPage(restaurantId: restaurantId, child: child),
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: 'restaurant/:id/info',
                  pageBuilder:
                      (context, state) => const NoTransitionPage(child: RestaurantInfoPage()),
                ),
                GoRoute(
                  path: 'restaurant/:id/menu',
                  pageBuilder:
                      (context, state) => const NoTransitionPage(child: RestaurantMenuPage()),
                  routes: [
                    GoRoute(
                      path: ':dishId',
                      pageBuilder: (context, state) {
                        final dishId = state.pathParameters['dishId']!;
                        // 這裡我們暫時用一個佔位頁面
                        return CupertinoPage(child: DishDetailPage(dishId: dishId));
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'restaurant/:id/reviews',
                  pageBuilder:
                      (context, state) => const NoTransitionPage(child: RestaurantReviewsPage()),
                ),
              ],
            ),
          ],
        ),
        GoRoute(path: '/ai', pageBuilder: (context, state) => NoTransitionPage(child: AiPage())),
        GoRoute(
          path: '/account',
          pageBuilder: (context, state) => NoTransitionPage(child: AccountPage()),
          routes: [
            GoRoute(
              path: 'history',
              pageBuilder: (context, state) => CupertinoPage(child: const BrowsingHistoryPage()),
            ),
            GoRoute(
              path: 'reviews',
              pageBuilder: (context, state) => CupertinoPage(child: const MyReviewsPage()),
            ),
          ],
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final currentPath = state.uri.path;
    if (currentPath == '/') {
      return '/loading';
    }
    return null;
  },
  errorBuilder:
      (context, state) => Scaffold(body: Center(child: Text('Page not found: ${state.uri.path}'))),
);

class NavigationService {
  late final GoRouter _router;

  NavigationService() {
    _router = routerConfig;
  }

  String _currentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }
}
