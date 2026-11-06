import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/profiles/profile.dart';

void main() {
  final json = {
    'id': '9c2d0000-0000-4000-8000-000000000001',
    'display_name': 'Ayşe',
    'language': 'en',
    'created_at': '2026-10-29T11:30:00+03:00',
  };

  test('reads a profile row from the database', () {
    final profile = Profile.fromJson(json);

    expect(profile.id, '9c2d0000-0000-4000-8000-000000000001');
    expect(profile.displayName, 'Ayşe');
    expect(profile.language, 'en');
    expect(profile.createdAt, DateTime.utc(2026, 10, 29, 8, 30));
    expect(profile.createdAt.isUtc, isTrue);
  });

  test('writes the same row it reads', () {
    final profile = Profile.fromJson(json);

    expect(Profile.fromJson(profile.toJson()), profile);
    expect(profile.toJson()['display_name'], 'Ayşe');
  });

  test('copyWith changes only the given fields', () {
    final profile = Profile.fromJson(json);
    final renamed = profile.copyWith(displayName: 'Ayşe H.');

    expect(renamed.displayName, 'Ayşe H.');
    expect(renamed.id, profile.id);
    expect(renamed.language, profile.language);
    expect(renamed.createdAt, profile.createdAt);
    expect(renamed, isNot(profile));
  });

  test('equal profiles have the same hash code', () {
    expect(Profile.fromJson(json).hashCode, Profile.fromJson(json).hashCode);
  });

  test('a blank display name counts as not picked yet', () {
    final profile = Profile.fromJson(json);

    expect(profile.hasDisplayName, isTrue);
    expect(profile.copyWith(displayName: '').hasDisplayName, isFalse);
    expect(profile.copyWith(displayName: '  ').hasDisplayName, isFalse);
  });
}
