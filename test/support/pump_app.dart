import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/app/app.dart';
import 'package:home_app/auth/auth_providers.dart';
import 'package:home_app/profiles/profile_providers.dart';

import '../auth/fake_auth_repository.dart';
import '../profiles/fake_profile_repository.dart';

/// Starts the whole app on fake repositories and waits until it settles.
Future<void> pumpApp(
  WidgetTester tester, {
  required FakeAuthRepository auth,
  required FakeProfileRepository profiles,
  Locale? locale,
}) async {
  if (locale != null) {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(profiles),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}
