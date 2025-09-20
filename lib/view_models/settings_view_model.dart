import 'package:flutter/foundation.dart';

// This would be a real service that talks to Firebase Auth or another provider.
class AuthService with ChangeNotifier {
  bool _isLoggedIn = false;
  final String _userId = 'user_abc123'; // Hardcoded for now

  bool get isLoggedIn => _isLoggedIn;
  String get userId => _userId;

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _isLoggedIn = false;
    notifyListeners();
  }
}

// This would be a real service that talks to a persistent storage like SharedPreferences or Firestore.
class UserPreferencesService with ChangeNotifier {
  double _speechRate = 1.0;
  bool _isRealtimeCaptureEnabled = false;

  double get speechRate => _speechRate;
  bool get isRealtimeCaptureEnabled => _isRealtimeCaptureEnabled;

  void setSpeechRate(double rate) {
    if (rate >= 0.5 && rate <= 2.0) {
      _speechRate = rate;
      notifyListeners();
    }
  }

  void setRealtimeCapture(bool enabled) {
    _isRealtimeCaptureEnabled = enabled;
    notifyListeners();
  }
}


class SettingsViewModel extends ChangeNotifier {
  final AuthService authService;
  final UserPreferencesService prefsService;

  SettingsViewModel({required this.authService, required this.prefsService}) {
    // Listen to changes in the services and notify our own listeners.
    authService.addListener(notifyListeners);
    prefsService.addListener(notifyListeners);
  }

  // Expose properties from services
  bool get isLoggedIn => authService.isLoggedIn;
  double get speechRate => prefsService.speechRate;
  bool get isRealtimeCaptureEnabled => prefsService.isRealtimeCaptureEnabled;

  // Expose methods from services
  Future<void> login(String email, String password) => authService.login(email, password);
  Future<void> logout() => authService.logout();

  void setSpeechRate(double rate) => prefsService.setSpeechRate(rate);
  void setRealtimeCapture(bool enabled) => prefsService.setRealtimeCapture(enabled);

  @override
  void dispose() {
    // Clean up listeners when the ViewModel is disposed.
    authService.removeListener(notifyListeners);
    prefsService.removeListener(notifyListeners);
    super.dispose();
  }
}
