import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:foodie/repositories/user_repo.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final UserRepository _userRepository;

  AuthService(this._auth, this._googleSignIn, this._userRepository);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _getOrCreateUserInFirestore(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.message}");
      return null;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> _getOrCreateUserInFirestore(User user) async {
    final userDoc = await _userRepository.getUser(user.uid);
    if (!userDoc.exists) {
      await _userRepository.createUser(user);
    } else {
      final existingUserData = userDoc.data() as Map<String, dynamic>;
      if (existingUserData['userName'] != user.displayName ||
          existingUserData['photoURL'] != user.photoURL) {
        await _userRepository.updateUserProfile(
          user.uid,
          user.displayName ?? 'Foodie User',
          user.photoURL,
        );
      }
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
