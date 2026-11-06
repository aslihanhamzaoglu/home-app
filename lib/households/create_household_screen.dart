import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../core/device_time_zone.dart';
import '../l10n/app_localizations.dart';
import 'household.dart';
import 'household_providers.dart';
import 'module.dart';
import 'module_names.dart';

/// How long to wait for a saved Household to be listed.
const _openTimeout = Duration(seconds: 10);

/// Creates a Household in two steps: its name, then which Modules are on.
/// Nothing is saved until the second step, so quitting halfway leaves no
/// half-set-up Household behind.
///
/// After saving, the screen opens the new Household once the Households
/// stream lists it. If that takes longer than [_openTimeout] or the stream
/// fails, it says so; trying again loads the Households afresh instead of
/// saving a second Household.
class CreateHouseholdScreen extends ConsumerStatefulWidget {
  const CreateHouseholdScreen({super.key});

  @override
  ConsumerState<CreateHouseholdScreen> createState() =>
      _CreateHouseholdScreenState();
}

class _CreateHouseholdScreenState extends ConsumerState<CreateHouseholdScreen> {
  final _name = TextEditingController();
  final _modules = Module.values.toSet();
  var _choosingModules = false;
  String? _nameError;
  bool _busy = false;

  /// The Household just created, until it arrives on the Households stream.
  String? _createdId;

  /// Gives up waiting for [_createdId] to be listed.
  Timer? _openTimer;

  /// Once saved, the name and Modules can no longer change here.
  bool get _locked => _busy || _createdId != null;

  @override
  void dispose() {
    _openTimer?.cancel();
    _name.dispose();
    super.dispose();
  }

  void _toModules() {
    if (_name.text.trim().isEmpty) {
      setState(
        () => _nameError = AppLocalizations.of(context).householdNameEmpty,
      );
      return;
    }
    setState(() {
      _nameError = null;
      _choosingModules = true;
    });
  }

  Future<void> _create() async {
    if (_createdId != null) {
      // Already saved: only opening it failed. Load the list again.
      setState(() => _busy = true);
      _waitToOpen();
      ref.invalidate(householdsProvider);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final timeZone = await ref.read(deviceTimeZoneProvider.future);
      final household = await ref
          .read(householdRepositoryProvider)
          .createHousehold(
            name: _name.text.trim(),
            timeZone: timeZone,
            modules: {..._modules},
          );
      _createdId = household.id;
      _waitToOpen();
      _openWhenListed(ref.read(householdsProvider).value);
    } catch (error) {
      debugPrint('Creating a Household failed: $error');
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericError)));
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Opens the new Household once the Households stream lists it, so the
  /// router never sees a Household it does not know yet.
  void _openWhenListed(List<Household>? households) {
    final id = _createdId;
    if (!mounted || id == null || households == null) return;
    if (households.any((household) => household.id == id)) {
      _openTimer?.cancel();
      _createdId = null;
      context.go(Routes.household(id));
    }
  }

  void _waitToOpen() {
    _openTimer?.cancel();
    _openTimer = Timer(_openTimeout, () => _stopWaiting('timed out'));
  }

  /// Stops waiting for the new Household and lets the person try again.
  void _stopWaiting(Object reason) {
    _openTimer?.cancel();
    if (!mounted || !_busy) return;
    debugPrint('Opening the new Household failed: $reason');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).genericError)),
    );
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(householdsProvider, (_, next) {
      if (_createdId == null) return;
      if (next case AsyncError(:final error) when !next.isLoading) {
        _stopWaiting(error);
      } else {
        _openWhenListed(next.value);
      }
    });
    final l10n = AppLocalizations.of(context);

    return PopScope(
      // The back button returns from the Modules to the name.
      canPop: !_choosingModules,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_locked) setState(() => _choosingModules = false);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _choosingModules
              ? BackButton(
                  onPressed: _locked
                      ? null
                      : () => setState(() => _choosingModules = false),
                )
              : null,
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _choosingModules
                  ? _buildModulesStep(l10n)
                  : _buildNameStep(l10n),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameStep(AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.createHouseholdTitle, style: textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(l10n.createHouseholdExplanation, style: textTheme.bodyLarge),
        const SizedBox(height: 24),
        TextField(
          key: const Key('householdName'),
          controller: _name,
          autofocus: true,
          // Matches the limit on households.name.
          maxLength: 60,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _toModules(),
          decoration: InputDecoration(
            labelText: l10n.householdNameLabel,
            errorText: _nameError,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _toModules, child: Text(l10n.continueButton)),
      ],
    );
  }

  Widget _buildModulesStep(AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.moduleSetupTitle, style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(l10n.moduleSetupExplanation, style: textTheme.bodyLarge),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final module in Module.values)
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            title: Text(module.name(l10n)),
            subtitle: Text(module.description(l10n)),
            value: _modules.contains(module),
            onChanged: _locked
                ? null
                : (on) => setState(
                    () => on ? _modules.add(module) : _modules.remove(module),
                  ),
          ),
        const SizedBox(height: 12),
        // The database also refuses a Household with no Modules on.
        if (_modules.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              l10n.moduleSetupNoneSelected,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FilledButton(
            onPressed: _busy || _modules.isEmpty ? null : _create,
            child: Text(l10n.continueButton),
          ),
        ),
      ],
    );
  }
}
