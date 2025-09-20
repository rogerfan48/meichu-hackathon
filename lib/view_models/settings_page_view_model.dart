import 'package:flutter/foundation.dart';
import '../repositories/user_repository.dart';
import 'settings_view_model.dart' show AuthService, UserPreferencesService; // reuse existing lightweight services

class SettingsPageViewModel extends ChangeNotifier {
  SettingsPageViewModel({
    required this.authService,
    required this.prefs,
    required this.userRepository,
    required this.userId,
  }) {
    // Listen to preference changes and auto-persist to Firestore
    prefs.addListener(_onPreferencesChanged);
  }

  final AuthService authService;
  final UserPreferencesService prefs;
  final UserRepository userRepository;
  final String userId;

  bool get isLoggedIn => authService.isLoggedIn;
  double get speechRate => prefs.speechRate;
  bool get realtime => prefs.isRealtimeCaptureEnabled;

  Future<void> login() => authService.login('demo@example.com', 'pw');
  Future<void> logout() => authService.logout();
  
  void setSpeechRate(double v) {
    prefs.setSpeechRate(v);
    // Auto-persist handled by listener
  }
  
  void toggleRealtime(bool v) => prefs.setRealtimeCapture(v);

  /// Persist current speech rate to Firestore
  Future<void> persistSpeechRate() async {
    try {
      await userRepository.updateDefaultSpeechRate(userId, speechRate);
    } catch (e) {
      if (kDebugMode) print('Failed to persist speech rate: $e');
    }
  }

  void _onPreferencesChanged() {
    // Auto-persist speech rate changes
    persistSpeechRate();
    notifyListeners();
  }

  @override
  void dispose() {
    prefs.removeListener(_onPreferencesChanged);
    super.dispose();
  }
}
