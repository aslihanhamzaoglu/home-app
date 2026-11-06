import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../l10n/app_localizations.dart';
import '../profiles/profile_providers.dart';
import 'household.dart';
import 'household_providers.dart';

/// Lists the person's Households to open one, pick their Default Household
/// or create another. [currentId] is the Household open now.
Future<void> showHouseholdSwitcher(BuildContext context, String currentId) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _HouseholdSwitcher(currentId: currentId),
  );
}

class _HouseholdSwitcher extends ConsumerWidget {
  const _HouseholdSwitcher({required this.currentId});

  final String currentId;

  Future<void> _makeDefault(
    BuildContext context,
    WidgetRef ref,
    Household household,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final profiles = ref.read(profileRepositoryProvider);
    final profile = ref.read(currentProfileProvider).value;
    if (profile == null) return;
    // Closed first, so the message below is not hidden behind the sheet.
    Navigator.of(context).pop();
    try {
      // The open Household stays; the new default is used from the next
      // launch.
      await profiles.updateProfile(
        profile.id,
        defaultHouseholdId: household.id,
      );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.defaultHouseholdSaved(household.name))),
      );
    } catch (error) {
      debugPrint('Saving the Default Household failed: $error');
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final households = ref.watch(householdsProvider).value ?? const [];
    final defaultId = ref
        .watch(currentProfileProvider)
        .value
        ?.defaultHouseholdId;

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(
              l10n.yourHouseholdsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final household in households)
            ListTile(
              selected: household.id == currentId,
              leading: Icon(
                household.id == currentId ? Icons.home : Icons.home_outlined,
              ),
              title: Text(household.name),
              trailing: household.id == defaultId
                  ? Tooltip(
                      message: l10n.defaultHouseholdTooltip,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.star),
                      ),
                    )
                  : IconButton(
                      tooltip: l10n.makeDefaultHouseholdTooltip,
                      icon: const Icon(Icons.star_outline),
                      onPressed: () => _makeDefault(context, ref, household),
                    ),
              onTap: () {
                final router = GoRouter.of(context);
                Navigator.of(context).pop();
                router.go(Routes.household(household.id));
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.createHouseholdTitle),
            onTap: () {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              unawaited(router.push(Routes.createHousehold));
            },
          ),
        ],
      ),
    );
  }
}
