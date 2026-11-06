import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../core/supabase_client.dart';
import 'profile.dart';
import 'profile_repository.dart';
import 'supabase_profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(ref.watch(supabaseClientProvider)),
);

/// The signed-in person's profile, or null when signed out.
final currentProfileProvider = StreamProvider<Profile?>((ref) async* {
  final userId = await ref.watch(authUserIdProvider.future);
  if (userId == null) {
    yield null;
    return;
  }
  yield* ref.watch(profileRepositoryProvider).watchProfile(userId);
});

/// The language the app is shown in: the one saved in the signed-in
/// person's profile, or null to follow the phone. New people follow the
/// phone until they save their name, which also saves that language.
final appLocaleProvider = Provider<Locale?>((ref) {
  final profile = ref.watch(currentProfileProvider).value;
  if (profile == null || !profile.hasDisplayName) return null;
  return Locale(profile.language);
});
