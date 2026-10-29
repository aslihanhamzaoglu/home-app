import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/auth/auth_repository.dart';

import '../profiles/fake_profile_repository.dart';
import '../support/pump_app.dart';
import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository auth;

  Future<void> pumpSignIn(WidgetTester tester) async {
    auth = FakeAuthRepository();
    await pumpApp(tester, auth: auth, profiles: FakeProfileRepository([]));
  }

  Future<void> sendCodeTo(WidgetTester tester, String email) async {
    await tester.enterText(find.byKey(const Key('email')), email);
    await tester.tap(find.text('Email me a code'));
    await tester.pumpAndSettle();
  }

  testWidgets('signs in with Google', (tester) async {
    await pumpSignIn(tester);

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(auth.googleSignIns, 1);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('closing the Google picker shows no error', (tester) async {
    await pumpSignIn(tester);
    auth.googleError = const SignInCancelledException();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a failed Google sign-in says so', (tester) async {
    await pumpSignIn(tester);
    auth.googleError = StateError('network');

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't sign in with Google. Try again."),
      findsOneWidget,
    );
  });

  testWidgets('an invalid email address is not sent', (tester) async {
    await pumpSignIn(tester);

    await sendCodeTo(tester, 'ayse.example.com');

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(auth.sentCodesTo, isEmpty);
  });

  testWidgets('signs in with an emailed code', (tester) async {
    await pumpSignIn(tester);

    await sendCodeTo(tester, ' ayse@example.com ');
    expect(auth.sentCodesTo, ['ayse@example.com']);
    expect(
      find.text('We sent a 6-digit code to ayse@example.com.'),
      findsOneWidget,
    );

    await tester.enterText(find.byKey(const Key('code')), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(auth.verifiedCodes, [(email: 'ayse@example.com', code: '123456')]);
  });

  testWidgets('a wrong code says so and keeps what was typed', (tester) async {
    await pumpSignIn(tester);
    await sendCodeTo(tester, 'ayse@example.com');
    auth.verifyCodeError = const InvalidCodeException();

    await tester.enterText(find.byKey(const Key('code')), '654321');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('That code is wrong or has expired.'), findsOneWidget);
    expect(find.text('654321'), findsOneWidget);
  });

  testWidgets('a failed send keeps the email and offers no code step', (
    tester,
  ) async {
    await pumpSignIn(tester);
    auth.sendCodeError = StateError('offline');

    await sendCodeTo(tester, 'ayse@example.com');

    expect(
      find.text('Something went wrong. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(find.text('ayse@example.com'), findsOneWidget);
    expect(find.byKey(const Key('code')), findsNothing);
  });

  testWidgets('sends a new code, or goes back to change the email', (
    tester,
  ) async {
    await pumpSignIn(tester);
    await sendCodeTo(tester, 'ayse@example.com');

    await tester.tap(find.text('Send a new code'));
    await tester.pumpAndSettle();
    expect(auth.sentCodesTo, ['ayse@example.com', 'ayse@example.com']);
    expect(find.text('We sent a new code.'), findsOneWidget);
    // Let the snackbar go away; it covers the buttons below it.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use a different email'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('email')), findsOneWidget);
    expect(find.byKey(const Key('code')), findsNothing);
  });
}
