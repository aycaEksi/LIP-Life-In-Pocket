class TaskItem {
  final int id;
  final String period;
  final String title;
  final bool done;
  final DateTime? dueDate;

  TaskItem({
    required this.id,
    required this.period,
    required this.title,
    required this.done,
    required this.dueDate,
  });

  factory TaskItem.fromRow(Map<String, Object?> r) {
    return TaskItem(
      id: r['id'] as int,
      period: r['period'] as String,
      title: r['title'] as String,
      done: (r['done'] as int) == 1,
      dueDate: r['due_date'] == null
          ? null
          : DateTime.tryParse(r['due_date'] as String),
    );
  }

  factory TaskItem.fromApi(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as int,
      period: json['period'] as String,
      title: json['title'] as String,
      done: (json['done'] as int) == 1,
      dueDate: json['due_date'] == null
          ? null
          : DateTime.tryParse(json['due_date'] as String),
    );
  }
}

// UZAY KAPSÜLÜ ŞEKLİNDE GİZLİYOR METNİ !!! :) /-hayat

class CapsuleItem {
  final int id;
  final String note;
  final DateTime unlockAtUtc;

  CapsuleItem({
    required this.id,
    required this.note,
    required this.unlockAtUtc,
  });

  bool get isUnlocked => !unlockAtUtc.isAfter(DateTime.now().toUtc());

  factory CapsuleItem.fromRow(Map<String, Object?> r) {
    return CapsuleItem(
      id: r['id'] as int,
      note: r['note'] as String,
      unlockAtUtc: DateTime.parse(r['unlock_at'] as String),
    );
  }

  factory CapsuleItem.fromApi(Map<String, dynamic> json) {
    return CapsuleItem(
      id: json['id'] as int,
      note: json['note'] as String,
      unlockAtUtc: DateTime.parse(json['unlock_at'] as String),
    );
  }
}