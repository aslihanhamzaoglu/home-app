import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/households/household.dart';
import 'package:home_app/households/member.dart';
import 'package:home_app/households/supabase_household_repository.dart';
import 'package:home_app/households/supabase_member_repository.dart';

import '../support/local_supabase.dart';

void main() {
  test(
    'a just-created Household and its Member are listed once, also after changes',
    () async {
      final creator = await signUpNewPerson();
      addTearDown(creator.dispose);
      final households = SupabaseHouseholdRepository(creator);
      // Watch straight after creating, when Realtime may still deliver the
      // INSERTs that `.stream()` used to add a second time.
      final household = await households.createHousehold(
        name: 'Fresh Flat',
        timeZone: 'Europe/Istanbul',
      );
      final householdUpdates = <List<Household>>[];
      final memberUpdates = <List<Member>>[];
      final householdSubscription = households.watchHouseholds().listen(
        householdUpdates.add,
      );
      final memberSubscription = SupabaseMemberRepository(
        creator,
      ).watchMembers(household.id).listen(memberUpdates.add);
      addTearDown(householdSubscription.cancel);
      addTearDown(memberSubscription.cancel);
      await Future<void>.delayed(const Duration(seconds: 3));

      await households.updateHousehold(household.copyWith(name: 'Renamed'));
      await Future<void>.delayed(const Duration(seconds: 2));

      expect(householdUpdates, isNotEmpty);
      expect(memberUpdates, isNotEmpty);
      for (final update in householdUpdates) {
        expect(update, hasLength(1));
      }
      for (final update in memberUpdates) {
        expect(update, hasLength(1));
      }
      expect(householdUpdates.last.single.name, 'Renamed');
    },
    skip: skipWithoutLocalSupabase,
  );
}
