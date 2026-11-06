import '../l10n/app_localizations.dart';
import 'module.dart';

/// The translated name and description of each Module.
extension ModuleNames on Module {
  String name(AppLocalizations l10n) => switch (this) {
    Module.shoppingList => l10n.moduleShoppingList,
    Module.presence => l10n.modulePresence,
    Module.announcements => l10n.moduleAnnouncements,
    Module.tasks => l10n.moduleTasks,
    Module.houseInfo => l10n.moduleHouseInfo,
    Module.meals => l10n.moduleMeals,
  };

  String description(AppLocalizations l10n) => switch (this) {
    Module.shoppingList => l10n.moduleShoppingListDescription,
    Module.presence => l10n.modulePresenceDescription,
    Module.announcements => l10n.moduleAnnouncementsDescription,
    Module.tasks => l10n.moduleTasksDescription,
    Module.houseInfo => l10n.moduleHouseInfoDescription,
    Module.meals => l10n.moduleMealsDescription,
  };
}
