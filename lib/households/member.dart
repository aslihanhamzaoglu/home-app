/// A person's membership in one specific Household.
class Member {
  const Member({
    required this.id,
    required this.householdId,
    required this.userId,
    required this.isAdmin,
    required this.joinedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      userId: json['user_id'] as String,
      isAdmin: json['is_admin'] as bool,
      joinedAt: DateTime.parse(json['joined_at'] as String).toUtc(),
    );
  }

  final String id;
  final String householdId;

  /// The person's profile id (their auth user id).
  final String userId;
  final bool isAdmin;
  final DateTime joinedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'user_id': userId,
      'is_admin': isAdmin,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  Member copyWith({
    String? id,
    String? householdId,
    String? userId,
    bool? isAdmin,
    DateTime? joinedAt,
  }) {
    return Member(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      userId: userId ?? this.userId,
      isAdmin: isAdmin ?? this.isAdmin,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Member &&
        other.id == id &&
        other.householdId == householdId &&
        other.userId == userId &&
        other.isAdmin == isAdmin &&
        other.joinedAt == joinedAt;
  }

  @override
  int get hashCode => Object.hash(id, householdId, userId, isAdmin, joinedAt);
}
