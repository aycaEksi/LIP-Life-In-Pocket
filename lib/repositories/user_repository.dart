import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import '../models/user.dart';

class UserRepository {
  Database get db => AppDb.instance.db;

  // Create - Yeni kullanıcı ekleme
  Future<int> createUser(User user) async {
    return await db.insert('users', user.toMap());
  }

  // Read - Tüm kullanıcıları getirme
  Future<List<User>> getAllUsers() async {
    final result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }

  // Read - ID ile kullanıcı getirme
  Future<User?> getUserById(int id) async {
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Read - Email ile kullanıcı getirme (login için)
  Future<User?> getUserByEmail(String email) async {
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Read - Login kontrolü
  Future<User?> login(String email, String password) async {
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Update - Kullanıcı güncelleme
  Future<int> updateUser(User user) async {
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete - Kullanıcı silme
  Future<int> deleteUser(int id) async {
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
