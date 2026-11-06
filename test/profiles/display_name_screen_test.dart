import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/profiles/profile.dart';

import '../auth/fake_auth_repository.dart';
import '../support/pump_app.dart';
import 'fake_profile_repository.dart';

void main() {
  final newcomer = Profile(
    id: 'u1',
    displayName: '',
    language: 'tr',
    createdAt: DateTime.utc(2026, 10, 1),
  );

  late FakeProfileRepository profiles;

  Future<void> pumpNameScreen(WidgetTester tester) async {
    profiles = FakeProfileRepository([newcomer]);
    await pumpApp(
      tester,
      auth: FakeAuthRepository(userId: 'u1'),
      profiles: profiles,
    );
  }

  testWidgets('an empty name is not saved', (tester) async {
    await pumpNameScreen(tester);

    await tester.enterText(find.byKey(const Key('displayName')), '   ');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your name.'), findsOneWidget);
    expect(find.text('What should we call you?'), findsOneWidget);
  });

  testWidgets('a failed save says so and keeps the name', (tester) async {
    await pumpNameScreen(tester);
    profiles.updateError = StateError('offline');

    await tester.enterText(find.byKey(const Key('displayName')), 'Ayşe');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      find.text('Something went wrong. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(find.text('Ayşe'), findsOneWidget);
    expect(find.text('What should we call you?'), findsOneWidget);
  });
}
