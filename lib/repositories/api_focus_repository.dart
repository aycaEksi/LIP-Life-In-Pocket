import 'dart:convert';
import '../models/day_key.dart';
import '../models/focus_day_model.dart';
import '../models/personal_reminder_model.dart';
import '../services/api_service.dart';
import 'focus_repository.dart';

class ApiFocusRepository implements FocusRepository {
  @override
  Future<void> ensureTodaySeeded() async {
    // API'de otomatik oluşturulacak, burada bir şey yapmaya gerek yok
  }

  @override
  Future<FocusDay> getToday() async {
    try {
      final today = ymd(DateTime.now());
      final response = await ApiService.instance.getFocusDaily(today);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null) {
          return FocusDay.fromApi(data);
        }
      }
      
      // Veri yoksa boş döndür
      return FocusDay.empty(userId: 1, date: today);
    } catch (e) {
      print('getToday error: $e');
      final today = ymd(DateTime.now());
      return FocusDay.empty(userId: 1, date: today);
    }
  }

  Future<FocusDay> _save(FocusDay day) async {
    try {
      await ApiService.instance.saveFocusDaily(
        date: day.date,
        hydrationCount: day.hydrationCount,
        movementCount: day.movementCount,
      );
      return day;
    } catch (e) {
      print('_save error: $e');
      rethrow;
    }
  }

  @override
  Future<FocusDay> setHydrationCount(int count) async {
    final day = await getToday();
    final clamped = count.clamp(0, FocusDay.hydrationTarget);
    return _save(day.copyWith(hydrationCount: clamped));
  }

  @override
  Future<FocusDay> setMovementCount(int count) async {
    final day = await getToday();
    final clamped = count.clamp(0, FocusDay.movementTarget);
    return _save(day.copyWith(movementCount: clamped));
  }

  @override
  Future<List<PersonalReminder>> listTodayReminders() async {
    try {
      final today = ymd(DateTime.now());
      final response = await ApiService.instance.getPersonalReminders(today);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PersonalReminder.fromApi(json)).toList();
      }
      return [];
    } catch (e) {
      print('listTodayReminders error: $e');
      return [];
    }
  }

  @override
  Future<PersonalReminder> addPersonalReminder(String text) async {
    try {
      final today = ymd(DateTime.now());
      final clean = text.trim();
      if (clean.isEmpty) throw StateError("Empty reminder");

      final response = await ApiService.instance.createPersonalReminder(
        date: today,
        text: clean,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PersonalReminder.fromApi(data);
      }
      
      throw Exception('Failed to add reminder');
    } catch (e) {
      print('addPersonalReminder error: $e');
      rethrow;
    }
  }

  @override
  Future<void> togglePersonalReminder(int id, bool done) async {
    try {
      await ApiService.instance.updatePersonalReminder(
        id: id,
        done: done,
      );
    } catch (e) {
      print('togglePersonalReminder error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePersonalReminder(int id) async {
    try {
      await ApiService.instance.deletePersonalReminder(id);
    } catch (e) {
      print('deletePersonalReminder error: $e');
      rethrow;
    }
  }
}
