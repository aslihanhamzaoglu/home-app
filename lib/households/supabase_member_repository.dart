import 'package:supabase_flutter/supabase_flutter.dart';

import 'member.dart';
import 'member_repository.dart';

class SupabaseMemberRepository implements MemberRepository {
  SupabaseMemberRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<List<Member>> watchMembers(String householdId) {
    return _client
        .from('members')
        .stream(primaryKey: ['id'])
        .eq('household_id', householdId)
        .order('joined_at', ascending: true)
        .map((rows) => rows.map(Member.fromJson).toList());
  }

  @override
  Future<void> setAdmin(String memberId, {required bool isAdmin}) {
    return _guardLastAdmin(
      () => _client
          .from('members')
          .update({'is_admin': isAdmin})
          .eq('id', memberId),
    );
  }

  @override
  Future<void> removeMember(String memberId) {
    return _guardLastAdmin(
      () => _client.from('members').delete().eq('id', memberId),
    );
  }

  /// Turns the database's "last Admin" error into a [LastAdminException].
  Future<void> _guardLastAdmin(Future<void> Function() write) async {
    try {
      await write();
    } on PostgrestException catch (error) {
      if (error.hint == 'last_admin') throw const LastAdminException();
      rethrow;
    }
  }
}
