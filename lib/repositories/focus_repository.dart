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

  Future<void> ensureTodaySeeded();
}