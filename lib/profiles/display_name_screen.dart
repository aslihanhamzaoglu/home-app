import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'profile_providers.dart';

/// Asks a new person for the name their housemates see. Shown once, until
/// the name is saved.
class DisplayNameScreen extends ConsumerStatefulWidget {
  const DisplayNameScreen({super.key});

  @override
  ConsumerState<DisplayNameScreen> createState() => _DisplayNameScreenState();
}

class _DisplayNameScreenState extends ConsumerState<DisplayNameScreen> {
  final _name = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.displayNameEmpty);
      return;
    }
    final profile = ref.read(currentProfileProvider).value;
    if (profile == null) return;
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      // The router moves on once the saved name arrives on the profile stream.
      await ref
          .read(profileRepositoryProvider)
          .updateDisplayName(profile.id, name);
    } catch (error) {
      debugPrint('Saving the display name failed: $error');
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericError)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Text(l10n.displayNameTitle, style: textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(l10n.displayNameExplanation, style: textTheme.bodyLarge),
                const SizedBox(height: 24),
                TextField(
                  key: const Key('displayName'),
                  controller: _name,
                  enabled: !_busy,
                  autofocus: true,
                  // Matches the limit on profiles.display_name.
                  maxLength: 50,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.givenName],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    labelText: l10n.displayNameLabel,
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: Text(l10n.continueButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
