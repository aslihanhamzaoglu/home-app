import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/sign_in_screen.dart';
import '../households/create_household_screen.dart';
import '../households/household.dart';
import '../households/household_providers.dart';
import '../households/household_screen.dart';
import '../profiles/display_name_screen.dart';
import '../profiles/profile.dart';
import '../profiles/profile_providers.dart';
import '../profiles/settings_screen.dart';
import 'loading_screen.dart';

abstract final class Routes {
  static const loading = '/loading';
  static const signIn = '/sign-in';
  static const displayName = '/name';

  /// Opens the Default Household, or asks to create one.
  static const home = '/';
  static const createHousehold = '/households/new';
  static String household(String id) => '/households/$id';
  static const settings = '/settings';
}

/// Where the router sends someone at [location], given the signed-in
/// person's [profile] (null when signed out). Returns null to stay.
@visibleForTesting
String? authRedirect(AsyncValue<Profile?> profile, String location) {
  final String? target;
  if (!profile.hasValue) {
    target = Routes.loading;
  } else if (profile.value case final signedIn?) {
    target = signedIn.hasDisplayName ? null : Routes.displayName;
  } else {
    target = Routes.signIn;
  }
  if (target != null) return target == location ? null : target;
  // Signed in with a name: leave the sign-in steps behind.
  const signInSteps = {Routes.loading, Routes.signIn, Routes.displayName};
  return signInSteps.contains(location) ? Routes.home : null;
}

/// Where a signed-in person with a name goes at [location], given their
/// [households]. Returns null to stay.
///
/// [Routes.home] opens the Default Household, or the first one when the
/// person has no Default Household among them, or asks to create one when
/// they have none. A Household the person is not in sends them home.
String? _householdRedirect(
  AsyncValue<Profile?> profile,
  AsyncValue<List<Household>> households,
  String location,
) {
  // While the Households load or fail, the screen shows it. While either
  // reloads, for example right after signing in or out, its value is still
  // the previous person's, so wait for both.
  if (profile.isLoading || households.isLoading) return null;
  final defaultId = profile.value?.defaultHouseholdId;
  final list = households.value;
  if (list == null) return null;
  if (location == Routes.home) {
    if (list.isEmpty) return Routes.createHousehold;
    final opened =
        list.where((h) => h.id == defaultId).firstOrNull ?? list.first;
    return Routes.household(opened.id);
  }
  const prefix = '/households/';
  if (location.startsWith(prefix) && location != Routes.createHousehold) {
    final id = location.substring(prefix.length);
    if (!list.any((household) => household.id == id)) return Routes.home;
  }
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final profile = ValueNotifier(ref.read(currentProfileProvider));
  final households = ValueNotifier(ref.read(householdsProvider));
  ref.listen(currentProfileProvider, (_, next) => profile.value = next);
  ref.listen(householdsProvider, (_, next) => households.value = next);

  final router = GoRouter(
    initialLocation: Routes.loading,
    refreshListenable: Listenable.merge([profile, households]),
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (authRedirect(profile.value, location) case final target?) {
        return target;
      }
      if (profile.value.value == null) return null;
      return _householdRedirect(profile.value, households.value, location);
    },
    routes: [
      GoRoute(
        path: Routes.loading,
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.displayName,
        builder: (context, state) => const DisplayNameScreen(),
      ),
      // Shown only while the Households load; then redirected away.
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: Routes.createHousehold,
        builder: (context, state) => const CreateHouseholdScreen(),
      ),
      GoRoute(
        path: '/households/:id',
        builder: (context, state) =>
            HouseholdScreen(householdId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    profile.dispose();
    households.dispose();
  });
  return router;
});
