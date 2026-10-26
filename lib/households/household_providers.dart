import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// The signed-in person's Households.
final householdsProvider = StreamProvider<List<Household>>(
  (ref) => ref.watch(householdRepositoryProvider).watchHouseholds(),
);

/// The Members of one Household, by Household id.
final membersProvider = StreamProvider.family<List<Member>, String>(
  (ref, householdId) =>
      ref.watch(memberRepositoryProvider).watchMembers(householdId),
);
