import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodie/services/navigation.dart';
import 'package:foodie/services/theme.dart';
import 'package:foodie/pages/firestore_test_page/firestore_data_page.dart'; 
import 'package:foodie/theme/theme.dart';

class FoodieApp extends StatelessWidget {
  const FoodieApp({super.key});

  @override
  Widget build(BuildContext context) {
    MaterialTheme theme = MaterialTheme();

    final themeService = context.watch<ThemeService>();

    return MaterialApp.router(
      title: 'Foodie',
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: themeService.themeMode,
      routerConfig: routerConfig,
      restorationScopeId: 'app',
    );
  }
}

class TestFirebaseApp extends StatelessWidget {
  const TestFirebaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodie - Firestore Viewer',
      theme: MaterialTheme().light(),
      darkTheme: MaterialTheme().dark(),
      // instead of routerConfig, just show your FirestoreDataPage:
      home: const FirestoreDataPage(),
      // remove routerConfig/restorationScopeId if not needed here
    );
  }
}
