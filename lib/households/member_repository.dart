import 'member.dart';

/// Reads and changes the Members of a Household.
abstract interface class MemberRepository {
  /// The Members of [householdId], oldest first, updated live.
  Stream<List<Member>> watchMembers(String householdId);

  /// Makes a Member an Admin or takes it away. Only Admins may do this.
  ///
  /// Throws [LastAdminException] when it would leave the Household without
  /// an Admin.
  Future<void> setAdmin(String memberId, {required bool isAdmin});

  /// Removes a Member. A Member may remove themselves (leave the Household);
  /// only Admins may remove others.
  ///
  /// Throws [LastAdminException] when the last Admin tries to leave.
  Future<void> removeMember(String memberId);
}

/// The change would leave a Household without an Admin.
class LastAdminException implements Exception {
  const LastAdminException();

  @override
  String toString() => 'LastAdminException';
}
