import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/live_rows.dart';
import 'profile.dart';
import 'profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<Profile> watchProfile(String userId) {
    return liveRows(
      _client,
      table: 'profiles',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: userId,
      ),
      load: () => _client.from('profiles').select().eq('id', userId),
    ).map((rows) {
      // Every auth user gets a profile (see handle_new_user), so a missing
      // row means it is not readable, not that it is unset.
      if (rows.isEmpty) throw StateError('No profile for $userId');
      return Profile.fromJson(rows.single);
    });
  }

  @override
  Future<void> updateDisplayName(String userId, String displayName) {
    return _client
        .from('profiles')
        .update({'display_name': displayName})
        .eq('id', userId);
  }
}
