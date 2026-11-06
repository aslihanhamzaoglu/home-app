import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/households/module.dart';
import 'package:home_app/profiles/profile.dart';

import '../auth/fake_auth_repository.dart';
import '../profiles/fake_profile_repository.dart';
import '../support/pump_app.dart';
import 'fake_household_repository.dart';

void main() {
  final ayse = Profile(
    id: 'u1',
    displayName: 'Ayşe',
    language: 'en',
    defaultHouseholdId: null,
    createdAt: DateTime.utc(2026, 10, 1),
  );

  const allSix = {
    Module.shoppingList,
    Module.presence,
    Module.announcements,
    Module.tasks,
    Module.houseInfo,
    Module.meals,
  };

  late FakeHouseholdRepository households;

  Future<void> startWithoutHouseholds(WidgetTester tester) async {
    households = FakeHouseholdRepository([]);
    await pumpApp(
      tester,
      auth: FakeAuthRepository(userId: 'u1'),
      profiles: FakeProfileRepository([ayse]),
      households: households,
    );
  }

  /// Scrolls the screen (not the text field inside it) to [finder].
  Future<void> scrollTo(WidgetTester tester, Finder finder) {
    return tester.scrollUntilVisible(
      finder,
      100,
      scrollable: find.byType(Scrollable).first,
    );
  }

  Future<void> tapContinue(WidgetTester tester) async {
    await scrollTo(tester, find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  Future<void> enterName(WidgetTester tester, String name) async {
    await tester.enterText(find.byKey(const Key('householdName')), name);
    await tapContinue(tester);
  }

  testWidgets('a person with no Household creates one with every Module on', (
    tester,
  ) async {
    await startWithoutHouseholds(tester);
    expect(find.text('Create a Household'), findsOneWidget);

    await enterName(tester, ' Moda Flat ');
    for (final name in [
      'Shopping List',
      'Presence',
      'Announcements',
      'Tasks',
      'House Info',
      'Meals',
    ]) {
      await scrollTo(tester, find.text(name));
      expect(
        tester.widget<SwitchListTile>(
          find.widgetWithText(SwitchListTile, name),
        ),
        isA<SwitchListTile>().having((tile) => tile.value, 'value', isTrue),
      );
    }

    await tapContinue(tester);

    final household = households.created.single;
    expect(household.name, 'Moda Flat');
    expect(household.timeZone, phoneTimeZone);
    expect(household.modules, allSix);
    expect(find.widgetWithText(AppBar, 'Moda Flat'), findsOneWidget);
  });

  testWidgets('Modules switched off in setup start off', (tester) async {
    await startWithoutHouseholds(tester);
    await enterName(tester, 'Moda Flat');

    for (final name in ['Meals', 'Tasks']) {
      await scrollTo(tester, find.text(name));
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }
    await tapContinue(tester);

    expect(households.created.single.modules, {
      Module.shoppingList,
      Module.presence,
      Module.announcements,
      Module.houseInfo,
    });
  });

  testWidgets('at least one Module must stay on', (tester) async {
    await startWithoutHouseholds(tester);
    await enterName(tester, 'Moda Flat');

    for (final name in [
      'Shopping List',
      'Presence',
      'Announcements',
      'Tasks',
      'House Info',
      'Meals',
    ]) {
      await scrollTo(tester, find.text(name));
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }
    await scrollTo(tester, find.text('Continue'));

    expect(find.text('Switch on at least one Module.'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Continue'),
      ),
      isA<FilledButton>().having((button) => button.enabled, 'enabled', false),
    );

    await scrollTo(tester, find.text('Meals'));
    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();
    await tapContinue(tester);
    expect(households.created.single.modules, {Module.meals});
  });

  testWidgets('a Household needs a name', (tester) async {
    await startWithoutHouseholds(tester);

    await enterName(tester, '   ');

    expect(find.text('Enter a name for the Household.'), findsOneWidget);
    expect(find.text('Choose your Modules'), findsNothing);
  });

  testWidgets('a failed create says so and keeps the choices', (tester) async {
    await startWithoutHouseholds(tester);
    households.createError = StateError('offline');
    await enterName(tester, 'Moda Flat');
    await scrollTo(tester, find.text('Meals'));
    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();

    await tapContinue(tester);

    expect(
      find.text('Something went wrong. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(households.created, isEmpty);
    await scrollTo(tester, find.text('Meals'));
    expect(
      tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Meals'),
      ),
      isA<SwitchListTile>().having((tile) => tile.value, 'value', isFalse),
    );

    households.createError = null;
    // Let the message go away so it does not cover the button.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tapContinue(tester);
    expect(households.created.single.name, 'Moda Flat');
    expect(households.created.single.modules, isNot(contains(Module.meals)));
  });

  testWidgets('back from the Modules returns to the name', (tester) async {
    await startWithoutHouseholds(tester);
    await enterName(tester, 'Moda Flat');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Create a Household'), findsOneWidget);
    expect(find.text('Moda Flat'), findsOneWidget);
  });
}
