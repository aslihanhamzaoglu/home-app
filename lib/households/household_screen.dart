import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../l10n/app_localizations.dart';
import '../profiles/profile_providers.dart';
import 'household_providers.dart';
import 'household_switcher.dart';

/// One Household's space. Its Modules come in later tickets; for now it
/// greets the person.
class HouseholdScreen extends ConsumerWidget {
  const HouseholdScreen({super.key, required this.householdId});

  final String householdId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final households = ref.watch(householdsProvider);
    final household = households.value
        ?.where((household) => household.id == householdId)
        .firstOrNull;
    final name = ref.watch(currentProfileProvider).value?.displayName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: household == null
            ? null
            : Tooltip(
                message: l10n.switchHouseholdTooltip,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => showHouseholdSwitcher(context, householdId),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            household.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: switch (households) {
            AsyncValue(hasError: true, isLoading: false) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.genericError),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(householdsProvider),
                  child: Text(l10n.retryButton),
                ),
              ],
            ),
            // Not listed (yet): the router moves on if it never will be.
            _ when household == null => const CircularProgressIndicator(),
            _ => Text(
              l10n.homeGreeting(name),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          },
        ),
      ),
    );
  }
}
