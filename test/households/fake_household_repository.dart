import 'dart:async';

import 'package:home_app/households/household.dart';
import 'package:home_app/households/household_repository.dart';
import 'package:home_app/households/module.dart';

/// An in-memory [HouseholdRepository]. Created Households go down the
/// stream, like Supabase Realtime does. Without starting [households] the
/// stream waits for the test to [emit].
class FakeHouseholdRepository implements HouseholdRepository {
  FakeHouseholdRepository([List<Household>? households])
    : _households = households;

  List<Household>? _households;
  final _changes = StreamController<List<Household>>.broadcast();

  /// The Households created through [createHousehold], oldest first.
  final created = <Household>[];
  Object? createError;

  void emit(List<Household> households) {
    _households = households;
    _changes.add(households);
  }

  void fail(Object error) => _changes.addError(error);

  @override
  Stream<List<Household>> watchHouseholds() async* {
    if (_households case final households?) yield households;
    yield* _changes.stream;
  }

  @override
  Future<Household> createHousehold({
    required String name,
    required String timeZone,
    required Set<Module> modules,
  }) async {
    if (createError case final error?) throw error;
    final household = Household(
      id: 'created-${created.length + 1}',
      name: name,
      timeZone: timeZone,
      modules: modules,
      createdAt: DateTime.utc(2026, 11, 6),
    );
    created.add(household);
    emit(
      [...?_households, household]..sort((a, b) => a.name.compareTo(b.name)),
    );
    return household;
  }

  @override
  Future<void> updateHousehold(Household household) async {}
}
