import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/households/household.dart';
import 'package:home_app/households/module.dart';
import 'package:home_app/profiles/profile.dart';

import '../auth/fake_auth_repository.dart';
import '../profiles/fake_profile_repository.dart';
import '../support/pump_app.dart';
import 'fake_household_repository.dart';

void main() {
  final berlin = Household(
    id: 'h-berlin',
    name: 'Berlin Flat',
    timeZone: 'Europe/Berlin',
    modules: Module.values.toSet(),
    createdAt: DateTime.utc(2026, 10, 2),
  );

  Profile ayseWithDefault(String? householdId) => Profile(
    id: 'u1',
    displayName: 'Ayşe',
    language: 'en',
    defaultHouseholdId: householdId,
    createdAt: DateTime.utc(2026, 10, 1),
  );

  late FakeProfileRepository profiles;
  late FakeHouseholdRepository households;

  /// Launches the app for Ayşe, a Member of Berlin Flat and Moda Flat.
  Future<void> launch(WidgetTester tester) {
    return pumpApp(
      tester,
      auth: FakeAuthRepository(userId: 'u1'),
      profiles: profiles,
      households: households,
    );
  }

  setUp(() {
    households = FakeHouseholdRepository([berlin, modaFlat]);
  });

  Finder appBarTitle(String name) => find.widgetWithText(AppBar, name);

  testWidgets('the app opens to the Default Household', (tester) async {
    profiles = FakeProfileRepository([ayseWithDefault(modaFlat.id)]);

    await launch(tester);

    expect(appBarTitle('Moda Flat'), findsOneWidget);
  });

  testWidgets('without a Default Household it opens the first one', (
    tester,
  ) async {
    profiles = FakeProfileRepository([ayseWithDefault('a-household-she-left')]);

    await launch(tester);

    expect(appBarTitle('Berlin Flat'), findsOneWidget);
  });

  testWidgets('the switcher opens another Household', (tester) async {
    profiles = FakeProfileRepository([ayseWithDefault(berlin.id)]);
    await launch(tester);

    await tester.tap(find.byTooltip('Switch Household'));
    await tester.pumpAndSettle();
    expect(find.text('Your Households'), findsOneWidget);
    await tester.tap(find.text('Moda Flat'));
    await tester.pumpAndSettle();

    expect(appBarTitle('Moda Flat'), findsOneWidget);
    expect(find.text('Your Households'), findsNothing);
  });

  testWidgets('a new Default Household takes effect on next launch', (
    tester,
  ) async {
    profiles = FakeProfileRepository([ayseWithDefault(berlin.id)]);
    await launch(tester);

    await tester.tap(find.byTooltip('Switch Household'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Default Household: the app opens here'), findsOne);
    await tester.tap(find.byTooltip('Make this your Default Household'));
    await tester.pumpAndSettle();

    expect(
      find.text('Moda Flat opens next time you start the app.'),
      findsOneWidget,
    );
    expect(appBarTitle('Berlin Flat'), findsOneWidget);
    await tester.tap(find.byTooltip('Switch Household'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Moda Flat'),
        matching: find.byTooltip('Default Household: the app opens here'),
      ),
      findsOne,
    );

    await launch(tester);

    expect(appBarTitle('Moda Flat'), findsOneWidget);
  });

  testWidgets('a failed Default Household change says so', (tester) async {
    profiles = FakeProfileRepository([ayseWithDefault(berlin.id)]);
    await launch(tester);
    profiles.updateError = StateError('offline');

    await tester.tap(find.byTooltip('Switch Household'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Make this your Default Household'));
    await tester.pumpAndSettle();

    expect(
      find.text('Something went wrong. Check your connection and try again.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Switch Household'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Berlin Flat'),
        matching: find.byTooltip('Default Household: the app opens here'),
      ),
      findsOne,
    );
  });

  testWidgets('another Household can be created from the switcher', (
    tester,
  ) async {
    profiles = FakeProfileRepository([ayseWithDefault(berlin.id)]);
    await launch(tester);

    await tester.tap(find.byTooltip('Switch Household'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create a Household'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('householdName')), 'Bodrum');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Continue'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(appBarTitle('Bodrum'), findsOneWidget);
    expect(households.created.single.name, 'Bodrum');
  });
}
