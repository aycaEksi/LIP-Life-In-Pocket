import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import '../models/day_key.dart';
import '../models/focus_day_model.dart';
import '../models/personal_reminder_model.dart';
import '../services/session_service.dart';
import 'focus_repository.dart';

class SqliteFocusRepository implements FocusRepository {
  Database get _db => AppDb.instance.db;

  Future<int> _uid() async {
    final uid = await SessionService.instance.getUserId();
    if (uid == null) throw StateError("Not logged in");
    return uid;
  }

  @override
  Future<void> ensureTodaySeeded() async {
    final uid = await _uid();
    final today = ymd(DateTime.now());

    final rows = await _db.query(
      'focus_daily',
      where: 'user_id=? AND date=?',
      whereArgs: [uid, today],
      limit: 1,
    );

    if (rows.isEmpty) {
      await _db.insert(
        'focus_daily',
        FocusDay.empty(userId: uid, date: today).toRow(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<FocusDay> getToday() async {
    await ensureTodaySeeded();
    final uid = await _uid();
    final today = ymd(DateTime.now());

    final rows = await _db.query(
      'focus_daily',
      where: 'user_id=? AND date=?',
      whereArgs: [uid, today],
      limit: 1,
    );

    if (rows.isEmpty) {
      return FocusDay.empty(userId: uid, date: today);
    }
    return FocusDay.fromRow(rows.first);
  }

  Future<FocusDay> _upsert(FocusDay day) async {
    await _db.insert(
      'focus_daily',
      day.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return day;
  }

  @override
  Future<FocusDay> setHydrationCount(int count) async {
    final day = await getToday();
    final clamped = count.clamp(0, FocusDay.hydrationTarget);
    return _upsert(day.copyWith(hydrationCount: clamped));
  }

  @override
  Future<FocusDay> setMovementCount(int count) async {
    final day = await getToday();
    final clamped = count.clamp(0, FocusDay.movementTarget);
    return _upsert(day.copyWith(movementCount: clamped));
  }

  @override
  Future<List<PersonalReminder>> listTodayReminders() async {
    final uid = await _uid();
    final today = ymd(DateTime.now());

    final rows = await _db.query(
      'personal_reminders',
      where: 'user_id=? AND date=?',
      whereArgs: [uid, today],
      orderBy: 'id DESC',
    );

    return rows.map(PersonalReminder.fromRow).toList();
  }

  @override
  Future<PersonalReminder> addPersonalReminder(String text) async {
    final uid = await _uid();
    final today = ymd(DateTime.now());
    final clean = text.trim();
    if (clean.isEmpty) throw StateError("Empty reminder");

    final id = await _db.insert('personal_reminders', {
      'user_id': uid,
      'date': today,
      'text': clean,
      'done': 0,
    });

    final rows = await _db.query(
      'personal_reminders',
      where: 'id=?',
      whereArgs: [id],
      limit: 1,
    );

    return PersonalReminder.fromRow(rows.first);
  }

  @override
  Future<void> togglePersonalReminder(int id, bool done) async {
    await _db.update(
      'personal_reminders',
      {'done': done ? 1 : 0},
      where: 'id=?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deletePersonalReminder(int id) async {
    await _db.delete('personal_reminders', where: 'id=?', whereArgs: [id]);
  }
}
