import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ── App user model ───────────────────────────────────────────────────────────

enum AuthMode { google, anonymous, unauthenticated }

class AppUser {
  final String displayName;
  final String? email;
  final String? photoUrl;
  final AuthMode mode;

  const AppUser({
    required this.displayName,
    this.email,
    this.photoUrl,
    required this.mode,
  });

  bool get isAnonymous => mode == AuthMode.anonymous;
  bool get isGoogle => mode == AuthMode.google;

  /// Features available to anonymous users (read-only civic info).
  static const anonymousAllowedRoutes = {'/chat', '/results', '/quiz'};

  factory AppUser.anonymous() => const AppUser(
        displayName: 'Guest',
        mode: AuthMode.anonymous,
      );

  factory AppUser.fromGoogle(GoogleSignInAccount account) => AppUser(
        displayName: account.displayName ?? account.email,
        email: account.email,
        photoUrl: account.photoUrl,
        mode: AuthMode.google,
      );
}

// ── Provider ────────────────────────────────────────────────────────────────

final authProvider =
    StateNotifierProvider<AuthNotifier, AppUser?>((ref) => AuthNotifier());

class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier() : super(null) {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      if (account != null) {
        state = AppUser.fromGoogle(account);
      }
    });
    _googleSignIn.signInSilently();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '781943476215-ls2li6q2822im54l3v6ubl79sg7v2l22.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  /// Full Google sign-in — unlocks all features.
  /// NOTE: google_sign_in_web v0.12+ requires renderButton for FedCM.
  /// The signIn() method is still functional but shows a deprecation warning.
  /// Migration to renderButton is tracked as a future task.
  Future<void> signIn() async {
    try {
      // Try silent sign-in first (returns existing session if available)
      final silentAccount = await _googleSignIn.signInSilently();
      if (silentAccount != null) {
        state = AppUser.fromGoogle(silentAccount);
        return;
      }
      // Fall back to interactive sign-in
      // ignore: deprecated_member_use
      final account = await _googleSignIn.signIn();
      if (account != null) {
        state = AppUser.fromGoogle(account);
      }
    } catch (e) {
      // FedCM may reject with NetworkError during local dev — safe to ignore.
      // The user remains on the login screen where they can retry.
      print('Google Sign-In: $e');
    }
  }

  /// Anonymous sign-in — read-only civic features (chat, results, quiz).
  void signInAnonymously() {
    state = AppUser.anonymous();
  }

  Future<void> signOut() async {
    if (state?.isGoogle ?? false) {
      await _googleSignIn.signOut();
    }
    state = null;
  }

  bool get isSignedIn => state != null;
  bool get isAnonymous => state?.isAnonymous ?? false;
  bool get isFullUser => state?.isGoogle ?? false;
}
