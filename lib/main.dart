import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'app.dart';
import 'firebase_options.dart';

// Repositories
import 'repositories/user_repository.dart';
import 'repositories/session_repository.dart';
import 'repositories/card_repository.dart';

// Services
import 'services/auth_service.dart';
import 'services/theme.dart';
import 'services/storage_service.dart';
import 'services/cloud_functions_service.dart';

// ViewModels
import 'view_models/account_vm.dart';
import 'view_models/upload_page_view_model.dart';
import 'view_models/sessions_page_view_model.dart';
import 'view_models/cards_page_view_model.dart';
import 'view_models/settings_page_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        // 1. Firebase Service Instances
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        Provider<FirebaseStorage>(create: (_) => FirebaseStorage.instance),
        Provider<FirebaseFunctions>(create: (_) => FirebaseFunctions.instance),
        Provider<GoogleSignIn>(create: (_) => GoogleSignIn()),

        // 2. Repositories
        Provider<UserRepository>(
          create: (context) => UserRepository(context.read<FirebaseFirestore>()),
        ),
        Provider<SessionRepository>(
          create: (context) => SessionRepository(context.read<FirebaseFirestore>()),
        ),
        Provider<CardRepository>(
          create: (context) => CardRepository(context.read<FirebaseFirestore>()),
        ),

        // 3. Services
        Provider<StorageService>(
          create: (context) => StorageService(context.read<FirebaseStorage>()),
        ),
        Provider<CloudFunctionsService>(
          create: (context) => CloudFunctionsService(functions: context.read<FirebaseFunctions>()),
        ),
        ProxyProvider3<FirebaseAuth, GoogleSignIn, UserRepository, AuthService>(
          update: (_, auth, googleSignIn, userRepo, previous) =>
              AuthService(auth, googleSignIn, userRepo),
        ),

        // 4. Global ViewModels
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
        ChangeNotifierProvider<AccountViewModel>(
          create: (context) => AccountViewModel(context.read<AuthService>()),
        ),

        // 5. Proxy ViewModels (depend on login state)
        ChangeNotifierProxyProvider<AccountViewModel, UploadPageViewModel?>(
          create: (_) => null,
          update: (context, accountViewModel, previous) {
            final userId = accountViewModel.firebaseUser?.uid;
            if (userId == null) return null;
            if (previous != null && previous.userId == userId) return previous;
            return UploadPageViewModel(
              sessionRepository: context.read<SessionRepository>(),
              storageService: context.read<StorageService>(),
              functionsService: context.read<CloudFunctionsService>(),
              userId: userId,
            );
          },
        ),

        ChangeNotifierProxyProvider<AccountViewModel, SessionsPageViewModel?>(
          create: (_) => null,
          update: (context, accountViewModel, previous) {
            final userId = accountViewModel.firebaseUser?.uid;
            if (userId == null) return null;
            if (previous != null && previous.userId == userId) return previous;
            // ** CRITICAL FIX HERE **
            // The constructor for SessionsPageViewModel requires `sessionRepository`, not `userRepository`.
            return SessionsPageViewModel(
              sessionRepository: context.read<SessionRepository>(),
              userId: userId,
            );
          },
        ),
        
        ChangeNotifierProxyProvider<AccountViewModel, CardsPageViewModel?>(
          create: (_) => null,
          update: (context, accountViewModel, previous) {
            final userId = accountViewModel.firebaseUser?.uid;
            if (userId == null) return null;
            if (previous != null && previous.userId == userId) return previous;
            return CardsPageViewModel(
              cardRepository: context.read<CardRepository>(),
              sessionRepository: context.read<SessionRepository>(),
              userId: userId,
            );
          },
        ),
        
        ChangeNotifierProxyProvider<AccountViewModel, SettingsPageViewModel?>(
          create: (_) => null,
          update: (context, accountViewModel, previous) {
            final userId = accountViewModel.firebaseUser?.uid;
            if (userId == null) return null;
            if (previous != null && previous.isLoggedIn == accountViewModel.isLoggedIn) return previous;
            return SettingsPageViewModel(
              userRepository: context.read<UserRepository>(),
              accountViewModel: accountViewModel,
              userId: userId,
            );
          },
        ),
      ],
      child: ShowCaseWidget(builder: (context) => const lexiaidApp()),
    ),
  );
}