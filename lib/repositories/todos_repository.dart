import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import '../services/session_service.dart';
import '../models/task_models.dart';

abstract class TodosRepository {
  Future<List<TaskItem>> getTasks(String period);
  Future<void> addTask(String period, String title, DateTime? due);
  Future<void> updateTask(int id, String title, DateTime? due);
  Future<void> toggleDone(int id, bool done);
  Future<void> deleteTask(int id);

  Future<List<CapsuleItem>> getCapsules();
  Future<void> addCapsule(String note, DateTime unlockAt);
  Future<void> deleteCapsule(int id);
}

class SqliteTodosRepository implements TodosRepository {
  final Database db;
  SqliteTodosRepository(this.db);

  Future<int> _uid() async {
    final uid = await SessionService.instance.getUserId();
    if (uid == null) throw Exception("Not logged in");
    return uid;
  }

  @override
  Future<List<TaskItem>> getTasks(String period) async {
    final uid = await _uid();
    final rows = await db.query(
      'tasks',
      where: 'user_id=? AND period=?',
      whereArgs: [uid, period],
      orderBy: 'id DESC',
    );
    return rows.map(TaskItem.fromRow).toList();
  }

  @override
  Future<void> addTask(String period, String title, DateTime? due) async {
    final uid = await _uid();
    await db.insert('tasks', {
      'user_id': uid,
      'period': period,
      'title': title,
      'done': 0,
      'due_date': due?.toIso8601String(),
    });
  }

  @override
  Future<void> updateTask(int id, String title, DateTime? due) async {
    await db.update(
      'tasks',
      {'title': title, 'due_date': due?.toIso8601String()},
      where: 'id=?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> toggleDone(int id, bool done) async {
    await db.update(
      'tasks',
      {'done': done ? 1 : 0},
      where: 'id=?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteTask(int id) async {
    await db.delete('tasks', where: 'id=?', whereArgs: [id]);
  }

  @override
  Future<List<CapsuleItem>> getCapsules() async {
    final uid = await _uid();
    final rows = await db.query(
      'capsules',
      where: 'user_id=?',
      whereArgs: [uid],
      orderBy: 'unlock_at ASC',
    );
    return rows.map(CapsuleItem.fromRow).toList();
  }

  @override
  Future<void> addCapsule(String note, DateTime unlockAt) async {
    final uid = await _uid();
    await db.insert('capsules', {
      'user_id': uid,
      'title': 'Time Capsule',
      'note': note,
      'unlock_at': unlockAt.toUtc().toIso8601String(),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> deleteCapsule(int id) async {
    await db.delete('capsules', where: 'id=?', whereArgs: [id]);
  }
}

/// simple global access (later DI)
class Repos {
  static final TodosRepository todos = SqliteTodosRepository(AppDb.instance.db);
}
