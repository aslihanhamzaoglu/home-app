import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/profiles/profile.dart';

import '../auth/fake_auth_repository.dart';
import '../support/pump_app.dart';
import 'fake_profile_repository.dart';

void main() {
  final ayse = Profile(
    id: 'u1',
    displayName: 'Ayşe',
    language: 'en',
    createdAt: DateTime.utc(2026, 10, 1),
  );

  late FakeProfileRepository profiles;

  Future<void> openSettings(WidgetTester tester) async {
    profiles = FakeProfileRepository([ayse]);
    await pumpApp(
      tester,
      auth: FakeAuthRepository(userId: 'u1'),
      profiles: profiles,
    );
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
  }

  testWidgets('switching language changes the app at once', (tester) async {
    await openSettings(tester);
    expect(find.text('Language'), findsOneWidget);

    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();
    expect(find.text('Dil'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Merhaba, Ayşe!'), findsOneWidget);
  });

  testWidgets('a failed switch says so and keeps the language', (tester) async {
    await openSettings(tester);
    profiles.updateError = StateError('offline');

    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();

    expect(
      find.text('Something went wrong. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(find.text('Language'), findsOneWidget);
  });
}
