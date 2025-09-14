import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodie/services/auth_service.dart';

class AccountViewModel extends ChangeNotifier {
  final AuthService _authService;
  User? _firebaseUser;

  User? get firebaseUser => _firebaseUser;
  bool get isLoggedIn => _firebaseUser != null;

  AccountViewModel(this._authService) {
    _authService.authStateChanges.listen(_onAuthStateChanged);
    _firebaseUser = _authService.currentUser;
  }

  void _onAuthStateChanged(User? user) {
    _firebaseUser = user;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
