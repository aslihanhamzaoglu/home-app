import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/households/supabase_household_repository.dart';

import '../support/local_supabase.dart';

void main() {
  test(
    'a new Household reaches its creator and no one else',
    () async {
      final creator = await signUpNewPerson();
      final outsider = await signUpNewPerson();
      addTearDown(creator.dispose);
      addTearDown(outsider.dispose);
      final repository = SupabaseHouseholdRepository(creator);

      final household = await repository.createHousehold(
        name: 'Integration Flat',
        timeZone: 'Europe/Istanbul',
      );

      expect(household.name, 'Integration Flat');
      expect(household.timeZone, 'Europe/Istanbul');
      expect(await repository.watchHouseholds().first, [household]);
      expect(
        await SupabaseHouseholdRepository(outsider).watchHouseholds().first,
        isEmpty,
      );
    },
    skip: skipWithoutLocalSupabase,
  );

  test('an Admin renames their Household', () async {
    final creator = await signUpNewPerson();
    addTearDown(creator.dispose);
    final repository = SupabaseHouseholdRepository(creator);
    final household = await repository.createHousehold(
      name: 'Old Name',
      timeZone: 'Europe/Istanbul',
    );

    await repository.updateHousehold(household.copyWith(name: 'New Name'));

    expect(await repository.watchHouseholds().first, [
      household.copyWith(name: 'New Name'),
    ]);
  }, skip: skipWithoutLocalSupabase);
}
