import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authProvider = StateNotifierProvider<AuthNotifier, GoogleSignInAccount?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<GoogleSignInAccount?> {
  AuthNotifier() : super(null) {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      state = account;
    });
    _googleSignIn.signInSilently();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '781943476215-ls2li6q2822im54l3v6ubl79sg7v2l22.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<void> signIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (e) {
      print('Google Sign-In Error: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    state = null;
  }

  bool get isSignedIn => state != null;
}
