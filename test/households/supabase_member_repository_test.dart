import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/households/member_repository.dart';
import 'package:home_app/households/supabase_household_repository.dart';
import 'package:home_app/households/supabase_member_repository.dart';

import '../support/local_supabase.dart';

void main() {
  test(
    'the creator is the only Member and cannot leave as the last Admin',
    () async {
      final creator = await signUpNewPerson();
      addTearDown(creator.dispose);
      final household = await SupabaseHouseholdRepository(
        creator,
      ).createHousehold(name: 'Solo Flat', timeZone: 'Europe/Berlin');
      final repository = SupabaseMemberRepository(creator);

      final members = await repository.watchMembers(household.id).first;

      expect(members, hasLength(1));
      expect(members.single.userId, creator.auth.currentUser!.id);
      expect(members.single.isAdmin, isTrue);
      await expectLater(
        repository.removeMember(members.single.id),
        throwsA(isA<LastAdminException>()),
      );
      await expectLater(
        repository.setAdmin(members.single.id, isAdmin: false),
        throwsA(isA<LastAdminException>()),
      );
    },
    skip: skipWithoutLocalSupabase,
  );
}
