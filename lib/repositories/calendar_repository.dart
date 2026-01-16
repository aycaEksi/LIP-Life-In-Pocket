import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import '../services/session_service.dart';
import '../models/day_entry_model.dart';

abstract class CalendarRepository {
  Future<Set<int>> getDaysWithDataInMonth(DateTime viewMonthFirstDay);
  Future<DayEntry?> getEntryByDate(DateTime date);

  Future<void> upsertEntry({
    required DateTime date,
    required String? note,
    required String? photo1Path,
    required String? photo2Path,
  });

  Future<void> deleteEntryByDate(DateTime date);
}

class SqliteCalendarRepository implements CalendarRepository {
  final Database db;
  SqliteCalendarRepository(this.db);

  Future<int> _uid() async {
    final uid = await SessionService.instance.getUserId();
    if (uid == null) throw StateError("Not logged in");
    return uid;
  }

  @override
  Future<Set<int>> getDaysWithDataInMonth(DateTime viewMonthFirstDay) async {
    final uid = await _uid();

    final start = DateTime(viewMonthFirstDay.year, viewMonthFirstDay.month, 1);
    final end = DateTime(
      viewMonthFirstDay.year,
      viewMonthFirstDay.month + 1,
      1,
    );

    final rows = await db.query(
      'day_entries',
      columns: ['date'],
      where: 'user_id=? AND date>=? AND date<?',
      whereArgs: [uid, ymd(start), ymd(end)],
    );

    final out = <int>{};
    for (final r in rows) {
      final s = (r['date'] as String?) ?? '';
      if (s.length >= 10) {
        final dd = int.tryParse(s.substring(8, 10));
        if (dd != null) out.add(dd);
      }
    }
    return out;
  }

  @override
  Future<DayEntry?> getEntryByDate(DateTime date) async {
    final uid = await _uid();

    final rows = await db.query(
      'day_entries',
      where: 'user_id=? AND date=?',
      whereArgs: [uid, ymd(date)],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return DayEntry.fromRow(rows.first);
  }

  @override
  Future<void> upsertEntry({
    required DateTime date,
    required String? note,
    required String? photo1Path,
    required String? photo2Path,
  }) async {
    final uid = await _uid();

    final cleaned = (note ?? '').trim();

    await db.insert('day_entries', {
      'user_id': uid,
      'date': ymd(date),
      'note': cleaned.isEmpty ? null : cleaned,
      'photo1_path': photo1Path,
      'photo2_path': photo2Path,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteEntryByDate(DateTime date) async {
    final uid = await _uid();

    await db.delete(
      'day_entries',
      where: 'user_id=? AND date=?',
      whereArgs: [uid, ymd(date)],
    );
  }
}

class CalendarRepos {
  static final CalendarRepository calendar = SqliteCalendarRepository(
    AppDb.instance.db,
  );
}
