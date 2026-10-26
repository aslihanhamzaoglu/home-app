import 'dart:async';

import 'package:home_app/households/household.dart';
import 'package:home_app/households/household_repository.dart';

/// An in-memory [HouseholdRepository] whose stream the test drives.
class FakeHouseholdRepository implements HouseholdRepository {
  final _households = StreamController<List<Household>>.broadcast();

  void emit(List<Household> households) => _households.add(households);

  void fail(Object error) => _households.addError(error);

  @override
  Stream<List<Household>> watchHouseholds() => _households.stream;

  @override
  Future<Household> createHousehold({
    required String name,
    required String timeZone,
  }) async {
    return Household(
      id: 'new-household',
      name: name,
      timeZone: timeZone,
      createdAt: DateTime.utc(2026),
    );
  }

  @override
  Future<void> updateHousehold(Household household) async {}
}
