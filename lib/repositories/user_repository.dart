import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import '../models/user.dart';

class UserRepository {
  Database get db => AppDb.instance.db;

  Future<int> createUser(User user) async {
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getAllUsers() async {
    final result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }

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

  Future<int> updateUser(User user) async {
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}