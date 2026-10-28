import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/households/household.dart';

void main() {
  final json = {
    'id': '7d3f1c2e-0000-4000-8000-000000000001',
    'name': 'Moda flat',
    'time_zone': 'Europe/Istanbul',
    'created_at': '2026-10-26T08:30:00+00:00',
  };

  test('reads a Household row from the database', () {
    final household = Household.fromJson(json);

    expect(household.id, '7d3f1c2e-0000-4000-8000-000000000001');
    expect(household.name, 'Moda flat');
    expect(household.timeZone, 'Europe/Istanbul');
    expect(household.createdAt, DateTime.utc(2026, 10, 26, 8, 30));
    expect(household.createdAt.isUtc, isTrue);
  });

  test('writes the same row it reads', () {
    final household = Household.fromJson(json);

    expect(Household.fromJson(household.toJson()), household);
    expect(household.toJson()['time_zone'], 'Europe/Istanbul');
  });

  test('copyWith changes only the given fields', () {
    final household = Household.fromJson(json);
    final renamed = household.copyWith(name: 'Kadıköy flat');

    expect(renamed.name, 'Kadıköy flat');
    expect(renamed.timeZone, household.timeZone);
    expect(renamed.id, household.id);
    expect(renamed, isNot(household));
  });

  test('two Households with the same values are equal', () {
    expect(Household.fromJson(json), Household.fromJson({...json}));
    expect(
      Household.fromJson(json).hashCode,
      Household.fromJson({...json}).hashCode,
    );
  });
}
