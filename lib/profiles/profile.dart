/// A person, the same in every Household they belong to.
class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    required this.language,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      language: json['language'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }

  /// The person's auth user id.
  final String id;

  /// Empty until the person picks a name on their first sign-in.
  final String displayName;

  /// `tr` or `en`.
  final String language;
  final DateTime createdAt;

  bool get hasDisplayName => displayName.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'language': language,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? displayName,
    String? language,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Profile &&
        other.id == id &&
        other.displayName == displayName &&
        other.language == language &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, displayName, language, createdAt);
}
