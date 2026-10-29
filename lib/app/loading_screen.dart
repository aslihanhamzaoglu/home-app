import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../profiles/profile_providers.dart';

/// Shown while the app finds out who is signed in, or when that fails.
class LoadingScreen extends ConsumerWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(currentProfileProvider);

    return Scaffold(
      body: Center(
        child: profile.hasError && !profile.isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.loadingFailed),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref.invalidate(currentProfileProvider),
                    child: Text(l10n.retryButton),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
