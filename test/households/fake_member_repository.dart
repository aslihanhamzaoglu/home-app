import 'dart:async';

import 'package:home_app/households/member.dart';
import 'package:home_app/households/member_repository.dart';

/// An in-memory [MemberRepository] whose streams the test drives.
class FakeMemberRepository implements MemberRepository {
  final _members = StreamController<(String, List<Member>)>.broadcast();
  final watchedHouseholdIds = <String>[];

  void emit(String householdId, List<Member> members) =>
      _members.add((householdId, members));

  @override
  Stream<List<Member>> watchMembers(String householdId) {
    watchedHouseholdIds.add(householdId);
    return _members.stream
        .where((update) => update.$1 == householdId)
        .map((update) => update.$2);
  }

  @override
  Future<void> setAdmin(String memberId, {required bool isAdmin}) async {}

  @override
  Future<void> removeMember(String memberId) async {}
}
