import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Set with `--dart-define-from-file=env/local.json` (or env/prod.json).
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);

/// Connects to Supabase. Call once before `runApp`.
Future<void> initSupabase() async {
  if (_supabaseUrl.isEmpty || _supabasePublishableKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are not set. Run with '
      '--dart-define-from-file=env/local.json',
    );
  }
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabasePublishableKey,
  );
}

/// The Supabase client. Only repository implementations may use it
/// (see ADR-0002).
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
