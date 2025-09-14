// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:showcaseview/showcaseview.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'repositories/restaurant_repo.dart';
import 'repositories/review_repo.dart';
import 'repositories/user_repo.dart';
import 'services/ai_chat.dart';
import 'services/auth_service.dart';
import 'services/map_position.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'services/theme.dart';
import 'view_models/account_vm.dart';
import 'view_models/my_reviews_vm.dart';
import 'view_models/viewed_restaurants_vm.dart';
import 'view_models/all_restaurants_vm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // 1. Repositories (數據層)
        Provider<UserRepository>(create: (_) => UserRepository()),
        Provider<ReviewRepository>(create: (_) => ReviewRepository()),
        Provider<RestaurantRepository>(create: (_) => RestaurantRepository()),

        // 2. Firebase 服務實例
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<GoogleSignIn>(create: (_) => GoogleSignIn()),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<LocationService>(create: (_) => LocationService()),

        // 3. Services (服務層)
        ProxyProvider3<FirebaseAuth, GoogleSignIn, UserRepository, AuthService>(
          update:
              (_, auth, googleSignIn, userRepo, previous) =>
                  AuthService(auth, googleSignIn, userRepo),
        ),

        // 4. Global ViewModels & Notifiers
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
        ChangeNotifierProvider<MapPositionService>(create: (_) => MapPositionService()),
        ChangeNotifierProvider<AiChatService>(create: (_) => AiChatService()),
        ChangeNotifierProvider<AccountViewModel>(
          create: (context) => AccountViewModel(context.read<AuthService>()),
        ),
        // 全局提供 AllRestaurantViewModel，供地圖頁使用
        ChangeNotifierProvider<AllRestaurantViewModel>(
          create: (context) => AllRestaurantViewModel(context.read<RestaurantRepository>()),
        ),

        // 5. Proxy ViewModels (依賴登入狀態)
        ChangeNotifierProxyProvider<AccountViewModel, MyReviewViewModel?>(
          create: (_) => null,
          update: (context, accountViewModel, previous) {
            final userId = accountViewModel.firebaseUser?.uid;
            if (userId == null) return null;
            return MyReviewViewModel(
              userId,
              context.read<ReviewRepository>(),
              context.read<RestaurantRepository>(),
              context.read<UserRepository>(),
            );
          },
        ),
        ChangeNotifierProxyProvider<AccountViewModel, ViewedRestaurantsViewModel?>(
          create: (_) => null,
          update: (context, accountViewModel, previous) {
            final userId = accountViewModel.firebaseUser?.uid;
            if (userId == null) return null;
            return ViewedRestaurantsViewModel(
              userId,
              context.read<UserRepository>(),
              context.read<RestaurantRepository>(),
            );
          },
        ),
      ],
      child: ShowCaseWidget(builder: (context) => const FoodieApp()),
    ),
  );
}
