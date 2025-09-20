import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'account_vm.dart';

enum SettingsPageState { idle, loading, error }

class SettingsPageViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AccountViewModel _accountViewModel;
  final String _userId;

  StreamSubscription? _userProfileSubscription;
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  SettingsPageState _state = SettingsPageState.idle;
  SettingsPageState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _accountViewModel.isLoggedIn;
  String get userName => _userProfile?.userName ?? _accountViewModel.firebaseUser?.displayName ?? 'Guest';
  String get userEmail => _accountViewModel.firebaseUser?.email ?? '';
  String get userPhotoUrl => _userProfile?.photoURL ?? _accountViewModel.firebaseUser?.photoURL ?? '';

  SettingsPageViewModel({
    required UserRepository userRepository,
    required AccountViewModel accountViewModel,
    required String userId,
  })  : _userRepository = userRepository,
        _accountViewModel = accountViewModel,
        _userId = userId {
    _accountViewModel.addListener(notifyListeners);
    _listenToUserProfile();
  }

  void _setState(SettingsPageState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _listenToUserProfile() {
    _setState(SettingsPageState.loading);
    _userProfileSubscription?.cancel();
    // ** CHANGE HERE **
    _userProfileSubscription = _userRepository.watchUserProfile(_userId).listen(
      (profile) {
        _userProfile = profile;
        _setState(SettingsPageState.idle);
      },
      onError: (error) {
        _errorMessage = "Failed to load user profile: $error";
        _setState(SettingsPageState.error);
      },
    );
  }

  Future<void> updateSpeechRate(double rate) async {
    if (_userProfile == null) return;
    try {
      _userProfile = _userProfile!.copyWith(defaultSpeechRate: rate);
      notifyListeners();
      await _userRepository.updateDefaultSpeechRate(_userId, rate);
    } catch (e) {
      _errorMessage = "Failed to update speech rate: $e";
      _listenToUserProfile();
    }
  }

  Future<void> signInWithGoogle() async {
    await _accountViewModel.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _accountViewModel.signOut();
  }

  @override
  void dispose() {
    _accountViewModel.removeListener(notifyListeners);
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}