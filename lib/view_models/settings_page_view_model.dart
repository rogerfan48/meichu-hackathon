import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'account_vm.dart';

// 狀態枚舉，用於表示頁面當前的狀態
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

  // 從 AccountViewModel 直接獲取登入狀態和用戶基本資訊
  bool get isLoggedIn => _accountViewModel.isLoggedIn;
  String get userName => _accountViewModel.firebaseUser?.displayName ?? _userProfile?.userName ?? 'Guest';
  String get userEmail => _accountViewModel.firebaseUser?.email ?? '';
  String get userPhotoUrl => _accountViewModel.firebaseUser?.photoURL ?? '';

  SettingsPageViewModel({
    required UserRepository userRepository,
    required AccountViewModel accountViewModel,
    required String userId,
  })  : _userRepository = userRepository,
        _accountViewModel = accountViewModel,
        _userId = userId {
    // ** 關鍵修復：開始監聽 AccountViewModel 的變化 **
    // 當 AccountViewModel 調用 notifyListeners() 時，這個 ViewModel 也會跟著調用。
    _accountViewModel.addListener(notifyListeners);
    
    // 當 ViewModel 被創建時，立即開始監聽用戶資料
    _listenToUserProfile();
  }

  void _setState(SettingsPageState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  // 監聽來自 Firestore 的用戶資料流
  void _listenToUserProfile() {
    _setState(SettingsPageState.loading);
    _userProfileSubscription?.cancel();
    _userProfileSubscription = _userRepository.watchCompleteUserProfile(_userId).listen(
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

  // 更新語音速度
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

  // 登入和登出操作直接代理給 AccountViewModel
  Future<void> signInWithGoogle() async {
    await _accountViewModel.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _accountViewModel.signOut();
  }

  // 在 ViewModel 被銷毀時，取消所有訂閱和監聽
  @override
  void dispose() {
    // ** 關鍵修復：移除對 AccountViewModel 的監聽 **
    _accountViewModel.removeListener(notifyListeners);
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}