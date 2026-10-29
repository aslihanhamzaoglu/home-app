import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../l10n/app_localizations.dart';
import '../profiles/profile_providers.dart';

/// Where signed-in people land. The Household screens replace this in later
/// tickets.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (error) {
      debugPrint('Sign-out failed: $error');
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(currentProfileProvider).value?.displayName ?? '';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.homeGreeting(name),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => _signOut(context, ref),
                child: Text(l10n.signOutButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
