import '../database/database_helper.dart';
import '../models/journal.dart';

class JournalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create
  Future<int> createJournal(Journal journal) async {
    final db = await _dbHelper.database;
    return await db.insert('journals', journal.toMap());
  }

  // Read - Tüm günlük kayıtlarını getirme
  Future<List<Journal>> getAllJournals() async {
    final db = await _dbHelper.database;
    final result = await db.query('journals', orderBy: 'entry_date DESC');
    return result.map((map) => Journal.fromMap(map)).toList();
  }

  // Read - ID ile günlük getirme
  Future<Journal?> getJournalById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'journals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Journal.fromMap(result.first);
    }
    return null;
  }

  // Read - Kullanıcıya ait günlük kayıtlarını getirme
  Future<List<Journal>> getJournalsByUserId(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'journals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'entry_date DESC',
    );
    return result.map((map) => Journal.fromMap(map)).toList();
  }

  // Read - Tarihe göre günlük getirme
  Future<Journal?> getJournalByDate(int userId, String date) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'journals',
      where: 'user_id = ? AND entry_date = ?',
      whereArgs: [userId, date],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Journal.fromMap(result.first);
    }
    return null;
  }

  // Read - Tarih aralığına göre günlük kayıtları
  Future<List<Journal>> getJournalsByDateRange(int userId, String startDate, String endDate) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'journals',
      where: 'user_id = ? AND entry_date >= ? AND entry_date <= ?',
      whereArgs: [userId, startDate, endDate],
      orderBy: 'entry_date DESC',
    );
    return result.map((map) => Journal.fromMap(map)).toList();
  }

  // Read - Mood ID'ye göre günlükler
  Future<List<Journal>> getJournalsByMoodId(int moodId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'journals',
      where: 'mood_id = ?',
      whereArgs: [moodId],
      orderBy: 'entry_date DESC',
    );
    return result.map((map) => Journal.fromMap(map)).toList();
  }

  // Update
  Future<int> updateJournal(Journal journal) async {
    final db = await _dbHelper.database;
    return await db.update(
      'journals',
      journal.toMap(),
      where: 'id = ?',
      whereArgs: [journal.id],
    );
  }

  // Delete
  Future<int> deleteJournal(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'journals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete - Kullanıcının tüm günlük kayıtlarını silme
  Future<int> deleteJournalsByUserId(int userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'journals',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
