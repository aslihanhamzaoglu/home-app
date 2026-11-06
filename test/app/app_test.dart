import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/profiles/profile.dart';

import '../auth/fake_auth_repository.dart';
import '../profiles/fake_profile_repository.dart';
import '../support/pump_app.dart';

void main() {
  final ayse = Profile(
    id: 'u1',
    displayName: 'Ayşe',
    language: 'tr',
    createdAt: DateTime.utc(2026, 10, 1),
  );
  final newcomer = ayse.copyWith(displayName: '');

  testWidgets('the app starts with the terracotta Material 3 theme', (
    tester,
  ) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      profiles: FakeProfileRepository([]),
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Ev');
    expect(app.theme!.useMaterial3, isTrue);
    expect(
      app.theme!.colorScheme,
      ColorScheme.fromSeed(seedColor: const Color(0xFFC8653D)),
    );
    expect(app.darkTheme!.colorScheme.brightness, Brightness.dark);
  });

  testWidgets('signed-out people see the sign-in screen', (tester) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      profiles: FakeProfileRepository([]),
    );

    expect(find.text('Welcome to Ev'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('returning people go straight to the main page', (tester) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(userId: 'u1'),
      profiles: FakeProfileRepository([ayse]),
    );

    expect(find.text('Hi, Ayşe!'), findsOneWidget);
    expect(find.text('What should we call you?'), findsNothing);
  });

  testWidgets('a new person is asked for their name once', (tester) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository([newcomer]);
    await pumpApp(tester, auth: auth, profiles: profiles);

    auth.emit('u1');
    await tester.pumpAndSettle();
    expect(find.text('What should we call you?'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('displayName')), ' Ayşe ');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Hi, Ayşe!'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Ev'), findsOneWidget);

    auth.emit('u1');
    await tester.pumpAndSettle();
    expect(find.text('Hi, Ayşe!'), findsOneWidget);
  });

  testWidgets('the app is in Turkish on a Turkish phone', (tester) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      profiles: FakeProfileRepository([]),
      locale: const Locale('tr', 'TR'),
    );

    expect(find.text('Google ile devam et'), findsOneWidget);
  });

  testWidgets('the app falls back to Turkish for other languages', (
    tester,
  ) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      profiles: FakeProfileRepository([]),
      locale: const Locale('de', 'DE'),
    );

    expect(find.text('Google ile devam et'), findsOneWidget);
  });
}
