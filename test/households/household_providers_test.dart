import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/households/household.dart';
import 'package:home_app/households/household_providers.dart';
import 'package:home_app/households/member.dart';

import 'fake_household_repository.dart';
import 'fake_member_repository.dart';

void main() {
  final moda = Household(
    id: 'h1',
    name: 'Moda Flat',
    timeZone: 'Europe/Istanbul',
    createdAt: DateTime.utc(2026, 10, 1),
  );
  final berlin = Household(
    id: 'h2',
    name: 'Berlin Flat',
    timeZone: 'Europe/Berlin',
    createdAt: DateTime.utc(2026, 10, 2),
  );

  test('householdsProvider delivers each update from the repository', () async {
    final repository = FakeHouseholdRepository();
    final container = ProviderContainer(
      overrides: [householdRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final updates = <List<Household>>[];
    container.listen(householdsProvider, (_, next) {
      if (next case AsyncData(:final value)) updates.add(value);
    });

    repository.emit([moda]);
    repository.emit([moda, berlin]);
    await pumpEventQueue();

    expect(updates, [
      [moda],
      [moda, berlin],
    ]);
  });

  test('membersProvider watches the Members of the given Household', () async {
    final repository = FakeMemberRepository();
    final container = ProviderContainer(
      overrides: [memberRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final admin = Member(
      id: 'm1',
      householdId: 'h1',
      userId: 'u1',
      isAdmin: true,
      joinedAt: DateTime.utc(2026, 10, 1),
    );
    final subscription = container.listen(membersProvider('h1'), (_, _) {});
    addTearDown(subscription.close);

    repository.emit('h1', [admin]);
    await pumpEventQueue();

    expect(repository.watchedHouseholdIds, ['h1']);
    expect(container.read(membersProvider('h1')).value, [admin]);
  });

  test('householdsProvider surfaces repository errors', () async {
    final repository = FakeHouseholdRepository();
    final container = ProviderContainer(
      overrides: [householdRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(householdsProvider, (_, _) {});
    addTearDown(subscription.close);

    repository.fail(StateError('offline'));
    await pumpEventQueue();

    expect(container.read(householdsProvider).hasError, isTrue);
  });
}
