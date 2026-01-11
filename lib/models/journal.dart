class Journal {
  final int? id;
  final int userId;
  final int? moodId;
  final String title;
  final String content;
  final String entryDate;
  final String? createdAt;

  Journal({
    this.id,
    required this.userId,
    this.moodId,
    required this.title,
    required this.content,
    required this.entryDate,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'mood_id': moodId,
      'title': title,
      'content': content,
      'entry_date': entryDate,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Journal.fromMap(Map<String, dynamic> map) {
    return Journal(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      moodId: map['mood_id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      entryDate: map['entry_date'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Journal copyWith({
    int? id,
    int? userId,
    int? moodId,
    String? title,
    String? content,
    String? entryDate,
    String? createdAt,
  }) {
    return Journal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodId: moodId ?? this.moodId,
      title: title ?? this.title,
      content: content ?? this.content,
      entryDate: entryDate ?? this.entryDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
