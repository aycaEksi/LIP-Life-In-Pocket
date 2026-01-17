import 'dart:convert';
import '../services/api_service.dart';
import '../models/day_entry_model.dart';

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
      // Backend'de delete endpoint'i yok, boş bir entry kaydet
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

class CalendarRepos {
  static final CalendarRepository calendar = ApiCalendarRepository();
}
