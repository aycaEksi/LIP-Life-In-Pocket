class DayEntry {
  final String date; // yyyy-mm-dd
  final String? note;
  final String? photo1Path;
  final String? photo2Path;

  const DayEntry({
    required this.date,
    this.note,
    this.photo1Path,
    this.photo2Path,
  });

  factory DayEntry.fromRow(Map<String, Object?> r) {
    return DayEntry(
      date: (r['date'] as String?) ?? '',
      note: r['note'] as String?,
      photo1Path: r['photo1_path'] as String?,
      photo2Path: r['photo2_path'] as String?,
    );
  }
}

// helper (same as before)
String ymd(DateTime d) {
  final yy = d.year.toString().padLeft(4, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return "$yy-$mm-$dd";
}
