import '../models/focus_day_model.dart';
import '../models/personal_reminder_model.dart';

abstract class FocusRepository {
  Future<FocusDay> getToday();
  Future<FocusDay> setHydrationCount(int count);
  Future<FocusDay> setMovementCount(int count);

  Future<List<PersonalReminder>> listTodayReminders();
  Future<PersonalReminder> addPersonalReminder(String text);
  Future<void> togglePersonalReminder(int id, bool done);
  Future<void> deletePersonalReminder(int id);

  /// Called on app open (and also on page open):
  /// ensures daily data is for "today".
  Future<void> ensureTodaySeeded();
}
