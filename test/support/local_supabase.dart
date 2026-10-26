import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

/// Why integration tests are skipped, or null when local Supabase is set up.
const String? skipWithoutLocalSupabase = _supabaseUrl == ''
    ? 'Needs local Supabase: supabase start, then '
          'flutter test --dart-define-from-file=env/local.json'
    : null;

final _random = Random();

/// Signs up a new person on local Supabase and returns a client signed in as
/// them. The caller disposes it.
Future<SupabaseClient> signUpNewPerson() async {
  final client = SupabaseClient(
    _supabaseUrl,
    _publishableKey,
    authOptions: const AuthClientOptions(
      autoRefreshToken: false,
      authFlowType: AuthFlowType.implicit,
    ),
  );
  final email =
      'it-${DateTime.now().microsecondsSinceEpoch}-'
      '${_random.nextInt(1 << 32)}@integration.local';
  await client.auth.signUp(email: email, password: 'integration-test');
  return client;
}
