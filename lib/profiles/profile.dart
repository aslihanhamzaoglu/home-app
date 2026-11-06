const _unchanged = Object();

/// A person, the same in every Household they belong to.
class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    required this.language,
    required this.defaultHouseholdId,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      language: json['language'] as String,
      defaultHouseholdId: json['default_household_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }

  /// The person's auth user id.
  final String id;

  /// Empty until the person picks a name on their first sign-in.
  final String displayName;

  /// `tr` or `en`.
  final String language;

  /// The Household the app opens to, or null when the person has not got
  /// one (yet). The database clears it when they leave that Household.
  final String? defaultHouseholdId;
  final DateTime createdAt;

  bool get hasDisplayName => displayName.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'language': language,
      'default_household_id': defaultHouseholdId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Pass `defaultHouseholdId: null` to clear it.
  Profile copyWith({
    String? id,
    String? displayName,
    String? language,
    Object? defaultHouseholdId = _unchanged,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      language: language ?? this.language,
      defaultHouseholdId: identical(defaultHouseholdId, _unchanged)
          ? this.defaultHouseholdId
          : defaultHouseholdId as String?,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Profile &&
        other.id == id &&
        other.displayName == displayName &&
        other.language == language &&
        other.defaultHouseholdId == defaultHouseholdId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, displayName, language, defaultHouseholdId, createdAt);
}
