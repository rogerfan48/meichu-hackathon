// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app.dart';
import 'repositories/user_repository.dart';
import 'services/auth_service.dart';
import 'services/theme.dart';
import 'view_models/account_vm.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // 1. Repositories (數據層)
        Provider<UserRepository>(create: (_) => UserRepository(FirebaseFirestore.instance)),

        // 2. Firebase 服務實例
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<GoogleSignIn>(create: (_) => GoogleSignIn()),

        // 3. Services (服務層)
        ProxyProvider3<FirebaseAuth, GoogleSignIn, UserRepository, AuthService>(
          update:
              (_, auth, googleSignIn, userRepo, previous) =>
                  AuthService(auth, googleSignIn, userRepo),
        ),

        // 4. Global ViewModels & Notifiers
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
        ChangeNotifierProvider<AccountViewModel>(
          create: (context) => AccountViewModel(context.read<AuthService>()),
        ),
        // 全局提供 AllRestaurantViewModel，供地圖頁使用

        // 5. Proxy ViewModels (依賴登入狀態)
        // ChangeNotifierProxyProvider<AccountViewModel, MyReviewViewModel?>(
        //   create: (_) => null,
        //   update: (context, accountViewModel, previous) {
        //     final userId = accountViewModel.firebaseUser?.uid;
        //     if (userId == null) return null;
        //     return MyReviewViewModel(
        //       userId,
        //       context.read<ReviewRepository>(),
        //       context.read<RestaurantRepository>(),
        //       context.read<UserRepository>(),
        //     );
        //   },
        // ),
      ],
      child: ShowCaseWidget(builder: (context) => const FoodieApp()),
    ),
  );
}
