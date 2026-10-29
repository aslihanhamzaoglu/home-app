import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/supabase_client.dart';
import 'auth_repository.dart';
import 'supabase_auth_repository.dart';

// Set with `--dart-define-from-file=env/local.json` (or env/prod.json).
const _googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(
    ref.watch(supabaseClientProvider),
    googleWebClientId: _googleWebClientId,
  ),
);

/// The signed-in person's id, or null when signed out.
final authUserIdProvider = StreamProvider<String?>(
  (ref) => ref.watch(authRepositoryProvider).watchUserId(),
);
