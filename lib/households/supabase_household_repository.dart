import 'package:supabase_flutter/supabase_flutter.dart';

import 'household.dart';
import 'household_repository.dart';

class SupabaseHouseholdRepository implements HouseholdRepository {
  SupabaseHouseholdRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<List<Household>> watchHouseholds() {
    // Row-level security limits the rows to the person's own Households.
    return _client
        .from('households')
        .stream(primaryKey: ['id'])
        .order('name', ascending: true)
        .map((rows) => rows.map(Household.fromJson).toList());
  }

  @override
  Future<Household> createHousehold({
    required String name,
    required String timeZone,
  }) async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'create_household',
      params: {'name': name, 'time_zone': timeZone},
    );
    return Household.fromJson(row);
  }

  @override
  Future<void> updateHousehold(Household household) async {
    await _client
        .from('households')
        .update({'name': household.name, 'time_zone': household.timeZone})
        .eq('id', household.id);
  }
}
