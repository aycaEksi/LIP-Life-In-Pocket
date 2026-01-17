import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import '../models/mood.dart';

class MoodRepository {
  Database get db => AppDb.instance.db;

  Future<int> createMood(Mood mood) async {
    return await db.insert('moods', mood.toMap());
  }

  Future<List<Mood>> getAllMoods() async {
    final result = await db.query('moods', orderBy: 'created_at DESC');
    return result.map((map) => Mood.fromMap(map)).toList();
  }

  Future<Mood?> getMoodById(int id) async {
    final result = await db.query(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Mood.fromMap(result.first);
    }
    return null;
  }

  Future<List<Mood>> getMoodsByUserId(int userId) async {
    final result = await db.query(
      'moods',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Mood.fromMap(map)).toList();
  }

  Future<Mood?> getTodayMoodByUserId(int userId) async {
    final today = DateTime.now();
    final startOfDay =
        DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59)
        .toIso8601String();

    final result = await db.query(
      'moods',
      where: 'user_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [userId, startOfDay, endOfDay],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Mood.fromMap(result.first);
    }
    return null;
  }

  Future<List<Mood>> getMoodsByDateRange(
      int userId, DateTime startDate, DateTime endDate) async {
    final result = await db.query(
      'moods',
      where: 'user_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String()
      ],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Mood.fromMap(map)).toList();
  }

  Future<int> updateMood(Mood mood) async {
    return await db.update(
      'moods',
      mood.toMap(),
      where: 'id = ?',
      whereArgs: [mood.id],
    );
  }

  Future<int> deleteMood(int id) async {
    return await db.delete(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMoodsByUserId(int userId) async {
    return await db.delete(
      'moods',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}