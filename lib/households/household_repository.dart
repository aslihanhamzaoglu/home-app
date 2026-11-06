import 'household.dart';
import 'module.dart';

/// Reads and writes the Households the signed-in person is a Member of.
abstract interface class HouseholdRepository {
  /// The signed-in person's Households, sorted by name, updated live.
  Stream<List<Household>> watchHouseholds();

  /// Creates a Household with [modules] switched on and the signed-in
  /// person as its first Admin. It becomes their Default Household if they
  /// have none yet.
  Future<Household> createHousehold({
    required String name,
    required String timeZone,
    required Set<Module> modules,
  });

  /// Saves a Household's name and time zone. Only Admins may do this.
  Future<void> updateHousehold(Household household);
}
