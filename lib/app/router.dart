import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/sign_in_screen.dart';
import '../profiles/display_name_screen.dart';
import '../profiles/profile.dart';
import '../profiles/profile_providers.dart';
import 'home_screen.dart';
import 'loading_screen.dart';

abstract final class Routes {
  static const loading = '/loading';
  static const signIn = '/sign-in';
  static const displayName = '/name';
  static const home = '/';
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

final routerProvider = Provider<GoRouter>((ref) {
  final profile = ValueNotifier(ref.read(currentProfileProvider));
  ref.listen(currentProfileProvider, (_, next) => profile.value = next);

  final router = GoRouter(
    initialLocation: Routes.loading,
    refreshListenable: profile,
    redirect: (context, state) =>
        authRedirect(profile.value, state.matchedLocation),
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
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    profile.dispose();
  });
  return router;
});
