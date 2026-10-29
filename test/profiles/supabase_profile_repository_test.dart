import 'package:flutter_test/flutter_test.dart';
import 'package:home_app/profiles/supabase_profile_repository.dart';

import '../support/local_supabase.dart';

void main() {
  test(
    'a new person has no name until they save one, live',
    () async {
      final client = await signUpNewPerson();
      addTearDown(client.dispose);
      final repository = SupabaseProfileRepository(client);
      final userId = client.auth.currentUser!.id;
      final profiles = repository.watchProfile(userId);

      final names = <String>[];
      final subscription = profiles.listen(
        (profile) => names.add(profile.displayName),
      );
      addTearDown(subscription.cancel);
      // Give Realtime a moment to subscribe (and to deliver the late INSERT
      // that liveRows guards against) before the change.
      await Future<void>.delayed(const Duration(seconds: 2));
      await repository.updateDisplayName(userId, 'Ayşe');
      await Future<void>.delayed(const Duration(seconds: 2));

      expect(names.first, '');
      expect(names.last, 'Ayşe');
    },
    skip: skipWithoutLocalSupabase,
  );
}
