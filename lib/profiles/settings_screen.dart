import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../l10n/app_localizations.dart';
import 'profile_providers.dart';

/// Each language in its own name, the same in every language, so people can
/// find theirs whatever the app is showing.
const _languageNames = {'tr': 'Türkçe', 'en': 'English'};

/// The signed-in person's settings: the language the app is in, and
/// signing out.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _chooseLanguage(
    BuildContext context,
    WidgetRef ref,
    String language,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final profile = ref.read(currentProfileProvider).value;
    if (profile == null || profile.language == language) return;
    try {
      // The app switches once the saved language arrives on the profile
      // stream.
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(profile.id, language: language);
    } catch (error) {
      debugPrint('Saving the language failed: $error');
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericError)));
    }
  }

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
    final language = ref.watch(currentProfileProvider).value?.language;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              l10n.languageHeading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioGroup<String>(
            groupValue: language,
            onChanged: (choice) {
              if (choice != null) {
                unawaited(_chooseLanguage(context, ref, choice));
              }
            },
            child: Column(
              children: [
                for (final MapEntry(key: code, value: name)
                    in _languageNames.entries)
                  RadioListTile<String>(value: code, title: Text(name)),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.signOutButton),
            onTap: () => _signOut(context, ref),
          ),
        ],
      ),
    );
  }
}
