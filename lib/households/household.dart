/// A group of people living together who share one space in the app.
class Household {
  const Household({
    required this.id,
    required this.name,
    required this.timeZone,
    required this.createdAt,
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'] as String,
      name: json['name'] as String,
      timeZone: json['time_zone'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }

  final String id;
  final String name;

  /// IANA time zone name, such as `Europe/Istanbul`.
  final String timeZone;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time_zone': timeZone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Household copyWith({
    String? id,
    String? name,
    String? timeZone,
    DateTime? createdAt,
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      timeZone: timeZone ?? this.timeZone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Household &&
        other.id == id &&
        other.name == name &&
        other.timeZone == timeZone &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, name, timeZone, createdAt);
}
