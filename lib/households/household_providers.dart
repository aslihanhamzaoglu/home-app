import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../core/supabase_client.dart';
import 'household.dart';
import 'household_repository.dart';
import 'member.dart';
import 'member_repository.dart';
import 'supabase_household_repository.dart';
import 'supabase_member_repository.dart';

final householdRepositoryProvider = Provider<HouseholdRepository>(
  (ref) => SupabaseHouseholdRepository(ref.watch(supabaseClientProvider)),
);

final memberRepositoryProvider = Provider<MemberRepository>(
  (ref) => SupabaseMemberRepository(ref.watch(supabaseClientProvider)),
);

/// The signed-in person's Households, sorted by name; none when signed out.
final householdsProvider = StreamProvider<List<Household>>((ref) async* {
  // Watching the person makes the list start again for whoever signs in.
  final userId = await ref.watch(authUserIdProvider.future);
  if (userId == null) {
    yield const [];
    return;
  }
  yield* ref.watch(householdRepositoryProvider).watchHouseholds();
});

/// The Members of one Household, by Household id.
final membersProvider = StreamProvider.family<List<Member>, String>(
  (ref, householdId) =>
      ref.watch(memberRepositoryProvider).watchMembers(householdId),
);
