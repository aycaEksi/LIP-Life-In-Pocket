class JournalPhoto {
  final int? id;
  final int journalId;
  final String photoPath;
  final String? createdAt;

  JournalPhoto({
    this.id,
    required this.journalId,
    required this.photoPath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'journal_id': journalId,
      'photo_path': photoPath,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory JournalPhoto.fromMap(Map<String, dynamic> map) {
    return JournalPhoto(
      id: map['id'] as int?,
      journalId: map['journal_id'] as int,
      photoPath: map['photo_path'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  JournalPhoto copyWith({
    int? id,
    int? journalId,
    String? photoPath,
    String? createdAt,
  }) {
    return JournalPhoto(
      id: id ?? this.id,
      journalId: journalId ?? this.journalId,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
