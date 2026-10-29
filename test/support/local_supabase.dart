import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

/// Why integration tests are skipped, or null when local Supabase is set up.
const String? skipWithoutLocalSupabase = _supabaseUrl == ''
    ? 'Needs local Supabase: supabase start, then '
          'flutter test --dart-define-from-file=env/local.json'
    : null;

// Local Supabase's email inbox (Mailpit).
const _inboxUrl = 'http://localhost:54324';

final _random = Random();

/// A signed-out client for local Supabase. The caller disposes it.
SupabaseClient newLocalClient() {
  return SupabaseClient(
    _supabaseUrl,
    _publishableKey,
    authOptions: const AuthClientOptions(
      autoRefreshToken: false,
      authFlowType: AuthFlowType.implicit,
    ),
  );
}

/// An email address no one has used yet.
String newEmail() {
  return 'it-${DateTime.now().microsecondsSinceEpoch}-'
      '${_random.nextInt(1 << 32)}@integration.local';
}

/// Signs up a new person on local Supabase and returns a client signed in as
/// them. The caller disposes it.
Future<SupabaseClient> signUpNewPerson() async {
  final client = newLocalClient();
  await client.auth.signUp(email: newEmail(), password: 'integration-test');
  return client;
}

/// The 6-digit code in the latest email local Supabase sent to [email].
Future<String> readSignInCode(String email) async {
  final http = HttpClient();
  try {
    for (var attempt = 0; attempt < 20; attempt++) {
      final search = await _getJson(
        http,
        Uri.parse(
          '$_inboxUrl/api/v1/search',
        ).replace(queryParameters: {'query': 'to:"$email"', 'limit': '1'}),
      );
      final messages = search['messages'] as List<dynamic>;
      if (messages.isNotEmpty) {
        final id = (messages.first as Map<String, dynamic>)['ID'] as String;
        final message = await _getJson(
          http,
          Uri.parse('$_inboxUrl/api/v1/message/$id'),
        );
        final text = message['Text'] as String;
        final code = RegExp(r'\b\d{6}\b').firstMatch(text);
        if (code != null) return code.group(0)!;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    throw StateError('No sign-in code arrived for $email');
  } finally {
    http.close();
  }
}

Future<Map<String, dynamic>> _getJson(HttpClient http, Uri uri) async {
  final request = await http.getUrl(uri);
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  return jsonDecode(body) as Map<String, dynamic>;
}
