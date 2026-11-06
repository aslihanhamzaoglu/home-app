import 'profile.dart';

/// Reads and changes people's profiles.
abstract interface class ProfileRepository {
  /// The profile of [userId], updated live.
  Stream<Profile> watchProfile(String userId);

  /// Saves the display name of [userId]. People may only change their own.
  Future<void> updateDisplayName(String userId, String displayName);
}
