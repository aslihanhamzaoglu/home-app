import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/auth/auth_providers.dart';
import 'package:home_app/profiles/profile.dart';
import 'package:home_app/profiles/profile_providers.dart';

import '../auth/fake_auth_repository.dart';
import 'fake_profile_repository.dart';

void main() {
  final ayse = Profile(
    id: 'u1',
    displayName: 'Ayşe',
    language: 'tr',
    createdAt: DateTime.utc(2026, 10, 1),
  );

  ProviderContainer containerFor(
    FakeAuthRepository auth,
    FakeProfileRepository profiles,
  ) {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(profiles),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(currentProfileProvider, (_, _) {});
    addTearDown(subscription.close);
    return container;
  }

  test('currentProfileProvider is null when signed out', () async {
    final profiles = FakeProfileRepository([ayse]);
    final container = containerFor(FakeAuthRepository(), profiles);
    await pumpEventQueue();

    expect(
      container.read(currentProfileProvider),
      const AsyncData<Profile?>(null),
    );
    expect(profiles.watchedUserIds, isEmpty);
  });

  test('currentProfileProvider follows sign-in and sign-out', () async {
    final auth = FakeAuthRepository();
    final container = containerFor(auth, FakeProfileRepository([ayse]));
    await pumpEventQueue();

    auth.emit('u1');
    await pumpEventQueue();
    expect(container.read(currentProfileProvider).value, ayse);

    auth.emit(null);
    await pumpEventQueue();
    expect(container.read(currentProfileProvider).value, isNull);
  });

  test('currentProfileProvider delivers a saved display name', () async {
    final profiles = FakeProfileRepository([ayse.copyWith(displayName: '')]);
    final container = containerFor(FakeAuthRepository(userId: 'u1'), profiles);
    await pumpEventQueue();

    await profiles.updateDisplayName('u1', 'Ayşe');
    await pumpEventQueue();

    expect(container.read(currentProfileProvider).value, ayse);
  });
}
