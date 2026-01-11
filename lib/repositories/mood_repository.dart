import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/mood.dart';

class MoodRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create
  Future<int> createMood(Mood mood) async {
    final db = await _dbHelper.database;
    return await db.insert('moods', mood.toMap());
  }

  // Read - Tüm mood kayıtlarını getirme
  Future<List<Mood>> getAllMoods() async {
    final db = await _dbHelper.database;
    final result = await db.query('moods', orderBy: 'created_at DESC');
    return result.map((map) => Mood.fromMap(map)).toList();
  }

  // Read - ID ile mood getirme
  Future<Mood?> getMoodById(int id) async {
    final db = await _dbHelper.database;
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

  // Read - Kullanıcıya ait mood kayıtlarını getirme
  Future<List<Mood>> getMoodsByUserId(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'moods',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Mood.fromMap(map)).toList();
  }

  // Read - Kullanıcının bugünkü mood kaydını getirme
  Future<Mood?> getTodayMoodByUserId(int userId) async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

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

  // Read - Tarih aralığına göre mood kayıtları
  Future<List<Mood>> getMoodsByDateRange(int userId, DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'moods',
      where: 'user_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [userId, startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Mood.fromMap(map)).toList();
  }

  // Update
  Future<int> updateMood(Mood mood) async {
    final db = await _dbHelper.database;
    return await db.update(
      'moods',
      mood.toMap(),
      where: 'id = ?',
      whereArgs: [mood.id],
    );
  }

  // Delete
  Future<int> deleteMood(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete - Kullanıcının tüm mood kayıtlarını silme
  Future<int> deleteMoodsByUserId(int userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'moods',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
