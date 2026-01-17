import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import '../models/task.dart';

class TaskRepository {
  Database get db => AppDb.instance.db;

  Future<int> createTask(Task task) async {
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final result = await db.query('tasks', orderBy: 'created_at DESC');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<Task?> getTaskById(int id) async {
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

  Future<List<Task>> getTasksByUserId(int userId) async {
    final result = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

// ayda yılda 1 olsa da muhakkak ara
  Future<List<Task>> getTasksByType(int userId, String taskType) async {
    final result = await db.query(
      'tasks',
      where: 'user_id = ? AND task_type = ?',
      whereArgs: [userId, taskType],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getCompletedTasks(int userId) async {
    final result = await db.query(
      'tasks',
      where: 'user_id = ? AND is_completed = ?',
      whereArgs: [userId, 1],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getIncompleteTasks(int userId) async {
    final result = await db.query(
      'tasks',
      where: 'user_id = ? AND is_completed = ?',
      whereArgs: [userId, 0],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTodayTasks(int userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final result = await db.query(
      'tasks',
      where: 'user_id = ? AND due_date = ?',
      whereArgs: [userId, today],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> toggleTaskCompletion(int id, bool isCompleted) async {
    return await db.update(
      'tasks',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTasksByUserId(int userId) async {
    return await db.delete(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteCompletedTasks(int userId) async {
    return await db.delete(
      'tasks',
      where: 'user_id = ? AND is_completed = ?',
      whereArgs: [userId, 1],
    );
  }
}