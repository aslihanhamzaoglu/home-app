import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/app/app.dart';
import 'package:home_app/auth/auth_providers.dart';
import 'package:home_app/core/device_time_zone.dart';
import 'package:home_app/households/household.dart';
import 'package:home_app/households/household_providers.dart';
import 'package:home_app/households/module.dart';
import 'package:home_app/profiles/profile_providers.dart';

import '../auth/fake_auth_repository.dart';
import '../households/fake_household_repository.dart';
import '../profiles/fake_profile_repository.dart';

/// The Household signed-in people are in unless a test says otherwise.
final modaFlat = Household(
  id: 'h-moda',
  name: 'Moda Flat',
  timeZone: 'Europe/Istanbul',
  modules: Module.values.toSet(),
  createdAt: DateTime.utc(2026, 10, 1),
);

/// The time zone the fake phone is in.
const phoneTimeZone = 'Europe/Istanbul';

/// Starts the whole app on fake repositories and waits until it settles.
/// Without [households], the person is a Member of [modaFlat] only.
Future<void> pumpApp(
  WidgetTester tester, {
  required FakeAuthRepository auth,
  required FakeProfileRepository profiles,
  FakeHouseholdRepository? households,
  Locale? locale,
}) async {
  if (locale != null) {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  await tester.pumpWidget(
    ProviderScope(
      // A new scope each time, so pumping again is a fresh launch.
      key: UniqueKey(),
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(profiles),
        householdRepositoryProvider.overrideWithValue(
          households ?? FakeHouseholdRepository([modaFlat]),
        ),
        deviceTimeZoneProvider.overrideWith((ref) async => phoneTimeZone),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}
