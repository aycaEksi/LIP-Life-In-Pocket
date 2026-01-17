import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../services/api_service.dart';
import '../models/day_entry_model.dart';
import '../db/app_db.dart';

abstract class CalendarRepository {
  Future<Set<int>> getDaysWithDataInMonth(DateTime viewMonthFirstDay);
  Future<DayEntry?> getEntryByDate(DateTime date);
  Future<String?> uploadPhoto(String filePath);

  Future<void> upsertEntry({
    required DateTime date,
    required String? note,
    required String? photo1Path,
    required String? photo2Path,
  });

  Future<void> deleteEntryByDate(DateTime date);
}

class ApiCalendarRepository implements CalendarRepository {
  @override
  Future<String?> uploadPhoto(String filePath) async {
    return await ApiService.instance.uploadPhoto(filePath);
  }

  @override
  Future<Set<int>> getDaysWithDataInMonth(DateTime viewMonthFirstDay) async {
    try {
      final response = await ApiService.instance.getAllDayEntries();
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        final start = DateTime(viewMonthFirstDay.year, viewMonthFirstDay.month, 1);
        final end = DateTime(viewMonthFirstDay.year, viewMonthFirstDay.month + 1, 1);
        
        final out = <int>{};
        for (final item in data) {
          final dateStr = item['date'] as String?;
          if (dateStr != null && dateStr.length >= 10) {
            final entryDate = DateTime.tryParse(dateStr);
            if (entryDate != null && 
                entryDate.isAfter(start.subtract(const Duration(days: 1))) &&
                entryDate.isBefore(end)) {
              final dd = int.tryParse(dateStr.substring(8, 10));
              if (dd != null) out.add(dd);
            }
          }
        }
        return out;
      }
      return {};
    } catch (e) {
      print('getDaysWithDataInMonth error: $e');
      return {};
    }
  }

  @override
  Future<DayEntry?> getEntryByDate(DateTime date) async {
    try {
      final response = await ApiService.instance.getDayEntry(ymd(date));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null) {
          return DayEntry.fromApi(data);
        }
      }
      return null;
    } catch (e) {
      print('getEntryByDate error: $e');
      return null;
    }
  }

  @override
  Future<void> upsertEntry({
    required DateTime date,
    required String? note,
    required String? photo1Path,
    required String? photo2Path,
  }) async {
    try {
      final cleaned = (note ?? '').trim();
      
      await ApiService.instance.saveDayEntry(
        date: ymd(date),
        note: cleaned.isEmpty ? null : cleaned,
        photo1Url: photo1Path,
        photo2Url: photo2Path,
      );
    } catch (e) {
      print('upsertEntry error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteEntryByDate(DateTime date) async {
    try {
      await ApiService.instance.saveDayEntry(
        date: ymd(date),
        note: null,
        photo1Url: null,
        photo2Url: null,
      );
    } catch (e) {
      print('deleteEntryByDate error: $e');
      rethrow;
    }
  }
}

String ymd(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

class LocalCalendarRepository implements CalendarRepository {
  @override
  Future<String?> uploadPhoto(String filePath) async {
    return filePath;
  }

  @override
  Future<Set<int>> getDaysWithDataInMonth(DateTime viewMonthFirstDay) async {
    try {
      final response = await ApiService.instance.getAllDayEntries();
      final Set<int> days = {};
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        final start = DateTime(viewMonthFirstDay.year, viewMonthFirstDay.month, 1);
        final end = DateTime(viewMonthFirstDay.year, viewMonthFirstDay.month + 1, 1);
        
        for (final item in data) {
          final dateStr = item['date'] as String?;
          if (dateStr != null && dateStr.length >= 10) {
            final entryDate = DateTime.tryParse(dateStr);
            if (entryDate != null && 
                entryDate.isAfter(start.subtract(const Duration(days: 1))) &&
                entryDate.isBefore(end)) {
              final dd = int.tryParse(dateStr.substring(8, 10));
              if (dd != null) days.add(dd);
            }
          }
        }
      }

      final db = await AppDb.instance.database;
      final localEntries = await db.query(
        'day_entries',
        where: 'user_id = ? AND date LIKE ?',
        whereArgs: [1, '${viewMonthFirstDay.year}-${viewMonthFirstDay.month.toString().padLeft(2, '0')}-%'],
      );

      for (final row in localEntries) {
        final dateStr = row['date'] as String?;
        if (dateStr != null && dateStr.length >= 10) {
          final dd = int.tryParse(dateStr.substring(8, 10));
          if (dd != null) days.add(dd);
        }
      }

      return days;
    } catch (e) {
      print('getDaysWithDataInMonth error: $e');
      return {};
    }
  }

  @override
  Future<DayEntry?> getEntryByDate(DateTime date) async {
    try {
      print('🔵 getEntryByDate çağrıldı: date=$date');
      String? note;
      String? photo1;
      String? photo2;

      final db = await AppDb.instance.database;
      final localRows = await db.query(
        'day_entries',
        where: 'user_id = ? AND date = ?',
        whereArgs: [1, ymd(date)],
        limit: 1,
      );

      if (localRows.isNotEmpty) {
        final row = localRows.first;
        photo1 = row['photo1_path'] as String?;
        photo2 = row['photo2_path'] as String?;
        print('✅ SQLite\'dan fotoğraflar alındı: photo1=$photo1, photo2=$photo2');
      } else {
        print('⚠️ SQLite\'da bu tarih için kayıt bulunamadı');
      }

      try {
        final response = await ApiService.instance.getDayEntry(ymd(date));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data != null) {
            note = data['note'] as String?;
            print('✅ Backend\'den not alındı: $note');
          }
        }
      } catch (e) {
        print('⚠️ Backend\'den veri alınamadı: $e');
      }

      if (note == null && photo1 == null && photo2 == null) {
        return null;
      }

      return DayEntry(
        date: ymd(date),
        note: note,
        photo1Path: photo1,
        photo2Path: photo2,
      );
    } catch (e) {
      print('❌ getEntryByDate error: $e');
      return null;
    }
  }

  @override
  Future<void> upsertEntry({
    required DateTime date,
    required String? note,
    required String? photo1Path,
    required String? photo2Path,
  }) async {
    try {
      print('🔵 upsertEntry çağrıldı: date=$date, photo1=$photo1Path, photo2=$photo2Path');
      
      // Notu backend'e kaydet
      final cleaned = (note ?? '').trim();
      await ApiService.instance.saveDayEntry(
        date: ymd(date),
        note: cleaned.isEmpty ? null : cleaned,
        photo1Url: null, 
        photo2Url: null,
      );
      print('Backend\'e not kaydedildi');

      final db = await AppDb.instance.database;
      final result = await db.insert(
        'day_entries',
        {
          'user_id': 1,
          'date': ymd(date),
          'note': null, 
          'photo1_path': photo1Path,
          'photo2_path': photo2Path,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print(' SQLite\'a fotoğraflar kaydedildi, id=$result');
    } catch (e) {
      print(' upsertEntry error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteEntryByDate(DateTime date) async {
    try {
      await ApiService.instance.saveDayEntry(
        date: ymd(date),
        note: null,
        photo1Url: null,
        photo2Url: null,
      );

      final db = await AppDb.instance.database;
      await db.delete(
        'day_entries',
        where: 'user_id = ? AND date = ?',
        whereArgs: [1, ymd(date)],
      );
    } catch (e) {
      print('deleteEntryByDate error: $e');
      rethrow;
    }
  }
}

class CalendarRepos {
  static final CalendarRepository calendar = LocalCalendarRepository();
}
