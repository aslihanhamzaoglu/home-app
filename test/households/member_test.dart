import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/households/member.dart';

void main() {
  final json = {
    'id': '5a1b0000-0000-4000-8000-000000000001',
    'household_id': '7d3f1c2e-0000-4000-8000-000000000001',
    'user_id': '9c2d0000-0000-4000-8000-000000000001',
    'is_admin': true,
    'joined_at': '2026-10-26T11:30:00+03:00',
  };

  test('reads a Member row from the database', () {
    final member = Member.fromJson(json);

    expect(member.id, '5a1b0000-0000-4000-8000-000000000001');
    expect(member.householdId, '7d3f1c2e-0000-4000-8000-000000000001');
    expect(member.userId, '9c2d0000-0000-4000-8000-000000000001');
    expect(member.isAdmin, isTrue);
    expect(member.joinedAt, DateTime.utc(2026, 10, 26, 8, 30));
    expect(member.joinedAt.isUtc, isTrue);
  });

  test('writes the same row it reads', () {
    final member = Member.fromJson(json);

    expect(Member.fromJson(member.toJson()), member);
    expect(member.toJson()['household_id'], json['household_id']);
    expect(member.toJson()['is_admin'], true);
  });

  test('copyWith changes only the given fields', () {
    final member = Member.fromJson(json);
    final demoted = member.copyWith(isAdmin: false);

    expect(demoted.isAdmin, isFalse);
    expect(demoted.userId, member.userId);
    expect(demoted.householdId, member.householdId);
    expect(demoted, isNot(member));
  });

  test('two Members with the same values are equal', () {
    expect(Member.fromJson(json), Member.fromJson({...json}));
    expect(Member.fromJson(json).hashCode, Member.fromJson({...json}).hashCode);
  });
}
