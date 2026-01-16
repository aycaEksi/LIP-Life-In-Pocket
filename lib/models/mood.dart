class Mood {
  final int? id;
  final int userId;
  final int energy;
  final int happiness;
  final int stress;
  final String? createdAt;

  Mood({
    this.id,
    required this.userId,
    required this.energy,
    required this.happiness,
    required this.stress,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'energy': energy,
      'happiness': happiness,
      'stress': stress,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Mood.fromMap(Map<String, dynamic> map) {
    return Mood(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      energy: map['energy'] as int,
      happiness: map['happiness'] as int,
      stress: map['stress'] as int,
      createdAt: map['created_at'] as String?,
    );
  }

  Mood copyWith({
    int? id,
    int? userId,
    int? energy,
    int? happiness,
    int? stress,
    String? createdAt,
  }) {
    return Mood(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      energy: energy ?? this.energy,
      happiness: happiness ?? this.happiness,
      stress: stress ?? this.stress,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
