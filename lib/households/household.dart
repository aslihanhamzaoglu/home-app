import 'package:flutter/foundation.dart';

import 'module.dart';

/// A group of people living together who share one space in the app.
class Household {
  const Household({
    required this.id,
    required this.name,
    required this.timeZone,
    required this.modules,
    required this.createdAt,
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'] as String,
      name: json['name'] as String,
      timeZone: json['time_zone'] as String,
      modules: {
        for (final key in (json['modules'] as List<dynamic>).cast<String>())
          ?Module.fromKey(key),
      },
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }

  final String id;
  final String name;

  /// IANA time zone name, such as `Europe/Istanbul`.
  final String timeZone;

  /// The Modules this Household has switched on.
  final Set<Module> modules;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time_zone': timeZone,
      'modules': [
        for (final module in Module.values)
          if (modules.contains(module)) module.key,
      ],
      'created_at': createdAt.toIso8601String(),
    };
  }

  Household copyWith({
    String? id,
    String? name,
    String? timeZone,
    Set<Module>? modules,
    DateTime? createdAt,
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      timeZone: timeZone ?? this.timeZone,
      modules: modules ?? this.modules,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Household &&
        other.id == id &&
        other.name == name &&
        other.timeZone == timeZone &&
        setEquals(other.modules, modules) &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    timeZone,
    Object.hashAllUnordered(modules),
    createdAt,
  );
}
