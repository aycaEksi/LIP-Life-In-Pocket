import '../database/database_helper.dart';
import '../models/journal_photo.dart';

class JournalPhotoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create
  Future<int> createJournalPhoto(JournalPhoto photo) async {
    final db = await _dbHelper.database;
    return await db.insert('journal_photos', photo.toMap());
  }

  // Read - Tüm fotoğrafları getirme
  Future<List<JournalPhoto>> getAllJournalPhotos() async {
    final db = await _dbHelper.database;
    final result = await db.query('journal_photos');
    return result.map((map) => JournalPhoto.fromMap(map)).toList();
  }

  // Read - ID ile fotoğraf getirme
  Future<JournalPhoto?> getJournalPhotoById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'journal_photos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return JournalPhoto.fromMap(result.first);
    }
    return null;
  }

  // Read - Günlüğe ait fotoğrafları getirme
  Future<List<JournalPhoto>> getPhotosByJournalId(int journalId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'journal_photos',
      where: 'journal_id = ?',
      whereArgs: [journalId],
      orderBy: 'created_at ASC',
    );
    return result.map((map) => JournalPhoto.fromMap(map)).toList();
  }

  // Update
  Future<int> updateJournalPhoto(JournalPhoto photo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'journal_photos',
      photo.toMap(),
      where: 'id = ?',
      whereArgs: [photo.id],
    );
  }

  // Delete
  Future<int> deleteJournalPhoto(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'journal_photos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete - Günlüğün tüm fotoğraflarını silme
  Future<int> deletePhotosByJournalId(int journalId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'journal_photos',
      where: 'journal_id = ?',
      whereArgs: [journalId],
    );
  }
}
