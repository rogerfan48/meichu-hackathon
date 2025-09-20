import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lexiaid/services/navigation.dart';
import 'package:lexiaid/services/theme.dart';
import 'package:lexiaid/theme/theme.dart';

class lexiaidApp extends StatelessWidget {
  const lexiaidApp({super.key});

  @override
  Widget build(BuildContext context) {
    MaterialTheme theme = MaterialTheme();

    final themeService = context.watch<ThemeService>();

    return MaterialApp.router(
      title: 'lexiaid',
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: themeService.themeMode,
      routerConfig: routerConfig,
      restorationScopeId: 'app',
    );
  }
}