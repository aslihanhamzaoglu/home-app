import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../households/household_providers.dart';
import '../l10n/app_localizations.dart';
import '../profiles/profile_providers.dart';

/// Shown while the app finds out who is signed in and which Households
/// they are in, or when that fails.
class LoadingScreen extends ConsumerWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(currentProfileProvider);
    final households = ref.watch(householdsProvider);
    final profileFailed = profile.hasError && !profile.isLoading;
    final householdsFailed = households.hasError && !households.isLoading;

    return Scaffold(
      body: Center(
        child: profileFailed || householdsFailed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.loadingFailed),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => profileFailed
                        ? ref.invalidate(currentProfileProvider)
                        : ref.invalidate(householdsProvider),
                    child: Text(l10n.retryButton),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
