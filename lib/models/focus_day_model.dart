class FocusDay {
  final int userId;
  final String date; // yyyy-mm-dd
  final int hydrationCount; // 0..10
  final int movementCount; // 0..2

  const FocusDay({
    required this.userId,
    required this.date,
    required this.hydrationCount,
    required this.movementCount,
  });

  static const int hydrationTarget = 10;
  static const int movementTarget = 2;

  FocusDay copyWith({int? hydrationCount, int? movementCount}) {
    return FocusDay(
      userId: userId,
      date: date,
      hydrationCount: hydrationCount ?? this.hydrationCount,
      movementCount: movementCount ?? this.movementCount,
    );
  }

  static FocusDay empty({required int userId, required String date}) {
    return FocusDay(
      userId: userId,
      date: date,
      hydrationCount: 0,
      movementCount: 0,
    );
  }

  factory FocusDay.fromRow(Map<String, Object?> r) {
    return FocusDay(
      userId: r['user_id'] as int,
      date: r['date'] as String,
      hydrationCount: (r['hydration_count'] as int?) ?? 0,
      movementCount: (r['movement_count'] as int?) ?? 0,
    );
  }

  factory FocusDay.fromApi(Map<String, dynamic> json) {
    return FocusDay(
      userId: json['user_id'] as int? ?? 1,
      date: json['date'] as String,
      hydrationCount: (json['hydration_count'] as int?) ?? 0,
      movementCount: (json['movement_count'] as int?) ?? 0,
    );
  }

  Map<String, Object?> toRow() => {
    'user_id': userId,
    'date': date,
    'hydration_count': hydrationCount,
    'movement_count': movementCount,
  };
}
