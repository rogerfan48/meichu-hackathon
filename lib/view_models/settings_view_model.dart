import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel();

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  Future<void> load(UserProfile profile) async {
    _profile = profile;
    notifyListeners();
  }

  Future<void> updateSpeechRate(double rate) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(defaultSpeechRate: rate);
    // TODO: persist to Firestore
    notifyListeners();
  }
}
