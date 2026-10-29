import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'auth_providers.dart';
import 'auth_repository.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Sign in with Google, or with a code emailed to the person.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();

  /// The address the code went to; null while the person types their email.
  String? _codeSentTo;
  String? _emailError;
  String? _codeError;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  AuthRepository get _auth => ref.read(authRepositoryProvider);

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context);
    await _run(_auth.signInWithGoogle, (error) {
      if (error is SignInCancelledException) return null;
      return l10n.googleSignInFailed;
    });
  }

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context);
    final email = _email.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _emailError = l10n.emailInvalid);
      return;
    }
    setState(() => _emailError = null);
    final sent = await _run(() => _auth.sendEmailCode(email));
    if (sent && mounted) setState(() => _codeSentTo = email);
  }

  Future<void> _resendCode() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final sent = await _run(() => _auth.sendEmailCode(_codeSentTo!));
    if (sent) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.codeResent)));
    }
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _codeError = null);
    await _run(
      () => _auth.verifyEmailCode(email: _codeSentTo!, code: _code.text.trim()),
      (error) {
        if (error is! InvalidCodeException) return l10n.genericError;
        setState(() => _codeError = l10n.codeInvalid);
        return null;
      },
    );
  }

  void _useDifferentEmail() {
    setState(() {
      _codeSentTo = null;
      _codeError = null;
      _code.clear();
    });
  }

  /// Runs [action] with the buttons disabled. On failure, shows the message
  /// [messageFor] picks (none when it returns null) and returns false.
  Future<bool> _run(
    Future<void> Function() action, [
    String? Function(Object error)? messageFor,
  ]) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
      return true;
    } catch (error) {
      debugPrint('Sign-in failed: $error');
      if (!mounted) return false;
      final message = messageFor == null
          ? l10n.genericError
          : messageFor(error);
      if (message != null) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final codeSentTo = _codeSentTo;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Text(l10n.signInTitle, style: textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(l10n.signInSubtitle, style: textTheme.bodyLarge),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _busy ? null : _signInWithGoogle,
                  icon: const Icon(Icons.account_circle_outlined),
                  label: Text(l10n.signInWithGoogle),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(l10n.signInOr),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                if (codeSentTo == null) ...[
                  TextField(
                    key: const Key('email'),
                    controller: _email,
                    enabled: !_busy,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendCode(),
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      errorText: _emailError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _busy ? null : _sendCode,
                    child: Text(l10n.sendCodeButton),
                  ),
                ] else ...[
                  Text(l10n.codeSentTo(codeSentTo)),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('code'),
                    controller: _code,
                    enabled: !_busy,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 6,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _verifyCode(),
                    decoration: InputDecoration(
                      labelText: l10n.codeLabel,
                      errorText: _codeError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _busy ? null : _verifyCode,
                    child: Text(l10n.verifyCodeButton),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _resendCode,
                    child: Text(l10n.resendCodeButton),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _useDifferentEmail,
                    child: Text(l10n.useDifferentEmailButton),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
