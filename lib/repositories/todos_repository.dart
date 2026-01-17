import 'dart:convert';
import '../services/api_service.dart';
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

class ApiTodosRepository implements TodosRepository {
  @override
  Future<List<TaskItem>> getTasks(String period) async {
    try {
      final response = await ApiService.instance.getTasks(period: period);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TaskItem.fromApi(json)).toList();
      }
      return [];
    } catch (e) {
      print('getTasks error: $e');
      return [];
    }
  }

  @override
  Future<void> addTask(String period, String title, DateTime? due) async {
    try {
      await ApiService.instance.createTask(
        period: period,
        title: title,
        dueDate: due?.toIso8601String(),
      );
    } catch (e) {
      print('addTask error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTask(int id, String title, DateTime? due) async {
    try {
      await ApiService.instance.updateTask(
        id: id,
        title: title,
        dueDate: due?.toIso8601String(),
      );
    } catch (e) {
      print('updateTask error: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleDone(int id, bool done) async {
    try {
      await ApiService.instance.updateTask(
        id: id,
        done: done,
      );
    } catch (e) {
      print('toggleDone error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    try {
      await ApiService.instance.deleteTask(id);
    } catch (e) {
      print('deleteTask error: $e');
      rethrow;
    }
  }

  @override
  Future<List<CapsuleItem>> getCapsules() async {
    try {
      final response = await ApiService.instance.getCapsules();

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CapsuleItem.fromApi(json)).toList();
      }
      return [];
    } catch (e) {
      print('getCapsules error: $e');
      return [];
    }
  }

  @override
  Future<void> addCapsule(String note, DateTime unlockAt) async {
    try {
      await ApiService.instance.createCapsule(
        title: 'Time Capsule',
        note: note,
        unlockAt: unlockAt.toUtc().toIso8601String(),
      );
    } catch (e) {
      print('addCapsule error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCapsule(int id) async {
    try {
      await ApiService.instance.deleteCapsule(id);
    } catch (e) {
      print('deleteCapsule error: $e');
      rethrow;
    }
  }
}

class Repos {
  static final TodosRepository todos = ApiTodosRepository();
}