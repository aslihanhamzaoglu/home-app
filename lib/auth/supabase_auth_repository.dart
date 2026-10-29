import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client, {required String googleWebClientId})
    : _googleWebClientId = googleWebClientId;

  final SupabaseClient _client;

  /// The Web OAuth client that Google issues ID tokens for, and that
  /// Supabase checks them against.
  final String _googleWebClientId;

  /// Google puts the SHA-256 hash of this nonce in the ID token and Supabase
  /// checks it against the raw value, so a token cannot be replayed from
  /// elsewhere. GoogleSignIn may be initialized only once, so one nonce
  /// serves the whole app run.
  final String _rawNonce = _randomNonce();
  Future<void>? _googleReady;

  @override
  Stream<String?> watchUserId() async* {
    String? userId = _client.auth.currentUser?.id;
    yield userId;
    await for (final state in _client.auth.onAuthStateChange) {
      final next = state.session?.user.id;
      if (next == userId) continue;
      userId = next;
      yield userId;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    await _initGoogle();
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SignInCancelledException();
      }
      rethrow;
    }
    final idToken = account.authentication.idToken;
    if (idToken == null) throw StateError('Google returned no ID token');
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      nonce: _rawNonce,
    );
  }

  @override
  Future<void> sendEmailCode(String email) {
    return _client.auth.signInWithOtp(email: email);
  }

  @override
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.email,
      );
    } on AuthApiException catch (error) {
      // Supabase reports a wrong code and an expired one the same way.
      if (error.code == 'otp_expired') throw const InvalidCodeException();
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    // Forget the Google account too, so the next sign-in shows the picker.
    await _initGoogle();
    await GoogleSignIn.instance.signOut();
  }

  Future<void> _initGoogle() {
    return _googleReady ??= GoogleSignIn.instance.initialize(
      serverClientId: _googleWebClientId,
      nonce: sha256.convert(utf8.encode(_rawNonce)).toString(),
    );
  }

  static String _randomNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
