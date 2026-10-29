import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/auth/auth_repository.dart';
import 'package:home_app/auth/supabase_auth_repository.dart';

import '../support/local_supabase.dart';

void main() {
  test('signs a new person in with an emailed code', () async {
    final client = newLocalClient();
    addTearDown(client.dispose);
    final repository = SupabaseAuthRepository(client, googleWebClientId: '');
    final email = newEmail();

    await repository.sendEmailCode(email);
    final code = await readSignInCode(email);
    await repository.verifyEmailCode(email: email, code: code);

    final userId = await repository.watchUserId().first;
    expect(userId, isNotNull);
    expect(client.auth.currentUser!.email, email);
  }, skip: skipWithoutLocalSupabase);

  test('a wrong code is rejected', () async {
    final client = newLocalClient();
    addTearDown(client.dispose);
    final repository = SupabaseAuthRepository(client, googleWebClientId: '');
    final email = newEmail();

    await repository.sendEmailCode(email);
    final code = await readSignInCode(email);
    final wrongCode = code == '000000' ? '111111' : '000000';

    await expectLater(
      repository.verifyEmailCode(email: email, code: wrongCode),
      throwsA(isA<InvalidCodeException>()),
    );
    expect(await repository.watchUserId().first, isNull);
  }, skip: skipWithoutLocalSupabase);
}
