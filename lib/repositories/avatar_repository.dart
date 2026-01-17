import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import '../models/avatar.dart';

class AvatarRepository {
  Database get db => AppDb.instance.db;

  Future<int> createAvatar(Avatar avatar) async {
    return await db.insert('avatars', avatar.toMap());
  }

  Future<List<Avatar>> getAllAvatars() async {
    final result = await db.query('avatars');
    return result.map((map) => Avatar.fromMap(map)).toList();
  }

  Future<Avatar?> getAvatarById(int id) async {
    final result = await db.query(
      'avatars',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Avatar.fromMap(result.first);
    }
    return null;
  }

  Future<List<Avatar>> getAvatarsByUserId(int userId) async {
    final result = await db.query(
      'avatars',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
    return result.map((map) => Avatar.fromMap(map)).toList();
  }

  Future<Avatar?> getLatestAvatarByUserId(int userId) async {
    final result = await db.query(
      'avatars',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Avatar.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateAvatar(Avatar avatar) async {
    return await db.update(
      'avatars',
      avatar.toMap(),
      where: 'id = ?',
      whereArgs: [avatar.id],
    );
  }

  Future<int> deleteAvatar(int id) async {
    return await db.delete(
      'avatars',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAvatarsByUserId(int userId) async {
    return await db.delete(
      'avatars',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}