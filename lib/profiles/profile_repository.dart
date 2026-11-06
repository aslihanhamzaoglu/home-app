import 'profile.dart';

/// Reads and changes people's profiles.
abstract interface class ProfileRepository {
  /// The profile of [userId], updated live.
  Stream<Profile> watchProfile(String userId);

  /// Saves the given fields of [userId]'s profile in one write; null fields
  /// are left as they are. People may only change their own profile.
  Future<void> updateProfile(
    String userId, {
    String? displayName,
    String? language,
  });
}
