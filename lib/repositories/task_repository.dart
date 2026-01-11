import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/task.dart';

class TaskRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create
  Future<int> createTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  // Read - Tüm görevleri getirme
  Future<List<Task>> getAllTasks() async {
    final db = await _dbHelper.database;
    final result = await db.query('tasks', orderBy: 'created_at DESC');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Read - ID ile görev getirme
  Future<Task?> getTaskById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Task.fromMap(result.first);
    }
    return null;
  }

  // Read - Kullanıcıya ait görevleri getirme
  Future<List<Task>> getTasksByUserId(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Read - Görev tipine göre getirme (daily, weekly, monthly, yearly)
  Future<List<Task>> getTasksByType(int userId, String taskType) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'user_id = ? AND task_type = ?',
      whereArgs: [userId, taskType],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Read - Tamamlanmış görevleri getirme
  Future<List<Task>> getCompletedTasks(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'user_id = ? AND is_completed = ?',
      whereArgs: [userId, 1],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Read - Tamamlanmamış görevleri getirme
  Future<List<Task>> getIncompleteTasks(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tasks',
      where: 'user_id = ? AND is_completed = ?',
      whereArgs: [userId, 0],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Read - Bugünün görevlerini getirme
  Future<List<Task>> getTodayTasks(int userId) async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final result = await db.query(
      'tasks',
      where: 'user_id = ? AND due_date = ?',
      whereArgs: [userId, today],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Update
  Future<int> updateTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Update - Görev durumunu güncelleme
  Future<int> toggleTaskCompletion(int id, bool isCompleted) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tasks',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete
  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete - Kullanıcının tüm görevlerini silme
  Future<int> deleteTasksByUserId(int userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Delete - Tamamlanmış görevleri silme
  Future<int> deleteCompletedTasks(int userId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'tasks',
      where: 'user_id = ? AND is_completed = ?',
      whereArgs: [userId, 1],
    );
  }
}
