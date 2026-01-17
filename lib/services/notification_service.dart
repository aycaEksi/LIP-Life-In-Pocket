// Notification servisi devre dışı bırakıldı
import '../repositories/focus_repository.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  Future<void> init() async {
    // Devre dışı
  }

  Future<void> reschedule5HourChecks({required FocusRepository repo}) async {
    // Devre dışı
  }

  Future<void> scheduleMoodInsights() async {
    // Devre dışı
  }

  Future<void> scheduleWaterReminders() async {
    // Devre dışı
  }

  Future<void> sendMoodInsightNotification({
    required int energy,
    required int happiness,
    required int stress,
    String? note,
  }) async {
    // Devre dışı
  }
}
