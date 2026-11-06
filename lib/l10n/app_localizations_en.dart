// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signInTitle => 'Welcome to Ev';

  @override
  String get signInSubtitle =>
      'Sign in to share lists, tasks and news with the people you live with.';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get signInOr => 'or';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailInvalid => 'Enter a valid email address.';

  @override
  String get sendCodeButton => 'Email me a code';

  @override
  String codeSentTo(String email) {
    return 'We sent a 6-digit code to $email.';
  }

  @override
  String get codeLabel => 'Code';

  @override
  String get codeInvalid => 'That code is wrong or has expired.';

  @override
  String get verifyCodeButton => 'Sign in';

  @override
  String get resendCodeButton => 'Send a new code';

  @override
  String get codeResent => 'We sent a new code.';

  @override
  String get useDifferentEmailButton => 'Use a different email';

  @override
  String get googleSignInFailed => 'Couldn\'t sign in with Google. Try again.';

  @override
  String get genericError =>
      'Something went wrong. Check your connection and try again.';

  @override
  String get displayNameTitle => 'What should we call you?';

  @override
  String get displayNameExplanation =>
      'The people you live with see this name, in every Household you join.';

  @override
  String get displayNameLabel => 'Your name';

  @override
  String get displayNameEmpty => 'Enter your name.';

  @override
  String get continueButton => 'Continue';

  @override
  String get loadingFailed => 'Couldn\'t load your account.';

  @override
  String get retryButton => 'Try again';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String get signOutButton => 'Sign out';
}
