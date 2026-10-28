import 'household.dart';

/// Reads and writes the Households the signed-in person is a Member of.
abstract interface class HouseholdRepository {
  /// The signed-in person's Households, sorted by name, updated live.
  Stream<List<Household>> watchHouseholds();

  /// Creates a Household with the signed-in person as its first Admin.
  Future<Household> createHousehold({
    required String name,
    required String timeZone,
  });

  /// Saves a Household's name and time zone. Only Admins may do this.
  Future<void> updateHousehold(Household household);
}
