import 'dart:async';

import 'package:home_app/profiles/profile.dart';
import 'package:home_app/profiles/profile_repository.dart';

/// An in-memory [ProfileRepository]. Saving a display name sends the changed
/// profile down the stream, like Supabase Realtime does.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository(List<Profile> profiles)
    : _profiles = {for (final profile in profiles) profile.id: profile};

  final Map<String, Profile> _profiles;
  final _changes = StreamController<Profile>.broadcast();

  Object? updateError;
  final watchedUserIds = <String>[];

  @override
  Stream<Profile> watchProfile(String userId) async* {
    watchedUserIds.add(userId);
    yield _profiles[userId]!;
    yield* _changes.stream.where((profile) => profile.id == userId);
  }

  @override
  Future<void> updateDisplayName(String userId, String displayName) async {
    if (updateError case final error?) throw error;
    final updated = _profiles[userId]!.copyWith(displayName: displayName);
    _profiles[userId] = updated;
    _changes.add(updated);
  }
}
