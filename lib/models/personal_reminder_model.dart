class PersonalReminder {
  final int id;
  final int userId;
  final String date; // yyyy-mm-dd
  final String text;
  final bool done;

  const PersonalReminder({
    required this.id,
    required this.userId,
    required this.date,
    required this.text,
    required this.done,
  });

  factory PersonalReminder.fromRow(Map<String, Object?> r) {
    return PersonalReminder(
      id: r['id'] as int,
      userId: r['user_id'] as int,
      date: r['date'] as String,
      text: r['text'] as String,
      done: (r['done'] as int) == 1,
    );
  }

  factory PersonalReminder.fromApi(Map<String, dynamic> json) {
    return PersonalReminder(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 1,
      date: json['date'] as String,
      text: json['text'] as String,
      done: (json['done'] as int) == 1,
    );
  }
}
