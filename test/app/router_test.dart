import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/app/router.dart';
import 'package:home_app/profiles/profile.dart';

void main() {
  final named = Profile(
    id: 'u1',
    displayName: 'Ayşe',
    language: 'tr',
    createdAt: DateTime.utc(2026, 10, 1),
  );
  final unnamed = named.copyWith(displayName: '');

  test('waits on the loading screen until the profile is known', () {
    expect(authRedirect(const AsyncLoading(), Routes.home), Routes.loading);
    expect(authRedirect(const AsyncLoading(), Routes.loading), isNull);
    expect(
      authRedirect(AsyncError(StateError('offline'), StackTrace.empty), '/'),
      Routes.loading,
    );
  });

  test('sends signed-out people to sign-in', () {
    expect(authRedirect(const AsyncData(null), Routes.home), Routes.signIn);
    expect(authRedirect(const AsyncData(null), Routes.loading), Routes.signIn);
    expect(authRedirect(const AsyncData(null), Routes.signIn), isNull);
  });

  test('sends people without a name to the name screen', () {
    expect(authRedirect(AsyncData(unnamed), Routes.home), Routes.displayName);
    expect(authRedirect(AsyncData(unnamed), Routes.signIn), Routes.displayName);
    expect(authRedirect(AsyncData(unnamed), Routes.displayName), isNull);
  });

  test('sends people with a name past the sign-in steps', () {
    expect(authRedirect(AsyncData(named), Routes.loading), Routes.home);
    expect(authRedirect(AsyncData(named), Routes.signIn), Routes.home);
    expect(authRedirect(AsyncData(named), Routes.displayName), Routes.home);
    expect(authRedirect(AsyncData(named), Routes.home), isNull);
  });
}
