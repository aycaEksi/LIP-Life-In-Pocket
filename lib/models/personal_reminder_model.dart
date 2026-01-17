class PersonalReminder {
  final int id;
  final int userId;
  final String date;
  final String text;
  final bool done;

  const PersonalReminder({
    required this.id,
    required this.userId,
    required this.date,
    required this.text,
    required this.done,
  });

// kullanıcı kendi hatırlatıcısını da ekleyebilsin diye ama garip çalışıyor dkbcofeje -hayat
// shsjjsd düzelttim sanırım -ayca

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