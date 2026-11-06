/// Signs people in and out.
abstract interface class AuthRepository {
  /// The signed-in person's id, or null when signed out. Starts with the
  /// current state, then follows every sign-in and sign-out.
  Stream<String?> watchUserId();

  /// Signs in with the Google account the person picks on the phone.
  ///
  /// Throws [SignInCancelledException] when they close the account picker.
  Future<void> signInWithGoogle();

  /// Emails a 6-digit sign-in code to [email]. A new address gets a new
  /// account.
  Future<void> sendEmailCode(String email);

  /// Signs in with the code [sendEmailCode] sent to [email].
  ///
  /// Throws [InvalidCodeException] when the code is wrong or has expired.
  Future<void> verifyEmailCode({required String email, required String code});

  Future<void> signOut();
}

/// The person closed the sign-in prompt without signing in.
class SignInCancelledException implements Exception {
  const SignInCancelledException();

  @override
  String toString() => 'SignInCancelledException';
}

/// The emailed sign-in code is wrong or has expired.
class InvalidCodeException implements Exception {
  const InvalidCodeException();

  @override
  String toString() => 'InvalidCodeException';
}
