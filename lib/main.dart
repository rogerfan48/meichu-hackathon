import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'repositories/session_repository.dart';
import 'repositories/card_repository.dart';
import 'services/ai_service.dart';
import 'services/ocr_service.dart';
import 'services/tts_service.dart';
import 'services/storage_service.dart';
import 'services/cloud_functions_service.dart';
import 'view_models/upload_view_model.dart';
import 'view_models/sessions_view_model.dart';
import 'view_models/cards_view_model.dart';
import 'view_models/game_view_model.dart';
import 'view_models/settings_view_model.dart';
import 'pages/upload_page.dart';
import 'pages/sessions_page.dart';
import 'pages/cards_page.dart';
import 'pages/game_page.dart';
import 'pages/settings_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp(const AppRoot());
  } catch (e) {
    runApp(FirebaseInitErrorApp(error: e.toString()));
  }
}

class FirebaseInitErrorApp extends StatelessWidget {
  const FirebaseInitErrorApp({super.key, required this.error});
  final String error;
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Initialization Error')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Firebase failed to initialize. Configure firebase_options.dart.\n\n$error'),
            ),
          ),
        ),
      );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMP user id for scaffolding; integrate auth later.
    const userId = 'user_abc123';
    final firestore = FirebaseFirestore.instance;
    final sessionRepo = SessionRepository(firestore);
    final cardRepo = CardRepository(firestore);
    final ai = AIService();
    final ocr = OCRService();
    final tts = TTSService(); // Provided for future speech features
    final storage = StorageService(firebase_storage.FirebaseStorage.instance);
    final functionsService = CloudFunctionsService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UploadViewModel(
              sessionRepository: sessionRepo,
              cardRepository: cardRepo,
              aiService: ai,
              ocrService: ocr,
              userId: userId,
              storageService: storage,
              functionsService: functionsService,
            )),
        ChangeNotifierProvider(create: (_) => SessionsViewModel(sessionRepository: sessionRepo, userId: userId, firestore: firestore)),
        ChangeNotifierProvider(create: (_) => CardsViewModel(cardRepository: cardRepo, userId: userId)
          ..initialize(cardRepo.watchAllCards(userId))),
        ChangeNotifierProvider(create: (_) => GameViewModel()),
  ChangeNotifierProvider(create: (_) => SettingsViewModel()),
  Provider<TTSService>.value(value: tts),
      ],
      child: MaterialApp(
        title: 'Dyslexia Assist',
        theme: AppTheme.light(),
        initialRoute: '/upload',
        routes: {
          '/upload': (_) => const UploadPage(),
          '/sessions': (_) => const SessionsPage(),
          '/cards': (_) => const CardsPage(),
          '/game': (_) => const GamePage(),
          '/settings': (_) => const SettingsPage(),
        },
      ),
    );
  }
}
