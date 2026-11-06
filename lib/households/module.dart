/// A built-in feature area that a Household switches on or off (ADR-0001).
///
/// Listed in the order the app shows them.
enum Module {
  shoppingList('shopping_list'),
  presence('presence'),
  announcements('announcements'),
  tasks('tasks'),
  houseInfo('house_info'),
  meals('meals');

  const Module(this.key);

  /// The name stored in `households.modules`.
  final String key;

  /// The Module stored as [key], or null for one this app version does not
  /// know yet.
  static Module? fromKey(String key) {
    for (final module in values) {
      if (module.key == key) return module;
    }
    return null;
  }
}
