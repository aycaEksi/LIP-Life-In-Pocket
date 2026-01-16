import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../repositories/focus_repository.dart';
import '../models/focus_day_model.dart';
import '../models/personal_reminder_model.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'focus_reminders';
  static const String _channelName = 'Focus reminders';

  Future<void> init() async {
    tz.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // Android channel + Android 13 permission
    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Reminds you about unfinished daily focus items.',
          importance: Importance.defaultImportance,
        ),
      );

      await androidImpl?.requestNotificationsPermission();
    }
  }

  Future<void> reschedule5HourChecks({required FocusRepository repo}) async {
    await _cancelRange(9000, 9050);

    final FocusDay day = await repo.getToday();
    final List<PersonalReminder> personals = await repo.listTodayReminders();

    final hydrationLeft = FocusDay.hydrationTarget - day.hydrationCount;
    final movementLeft = FocusDay.movementTarget - day.movementCount;
    final personalLeft = personals.where((p) => !p.done).length;

    if (hydrationLeft <= 0 && movementLeft <= 0 && personalLeft <= 0) return;

    final now = tz.TZDateTime.now(tz.local);
    final offsets = [5, 10, 15, 20];
    int nid = 9000;

    for (final h in offsets) {
      final when = now.add(Duration(hours: h));
      final body = _buildBody(
        hydrationLeft: hydrationLeft,
        movementLeft: movementLeft,
        personalLeft: personalLeft,
      );

      await _plugin.zonedSchedule(
        nid++,
        "Focus Hub",
        body,
        when,
        _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  String _buildBody({
    required int hydrationLeft,
    required int movementLeft,
    required int personalLeft,
  }) {
    final parts = <String>[];
    if (hydrationLeft > 0) parts.add("Hydration: $hydrationLeft left");
    if (movementLeft > 0) parts.add("Movement: $movementLeft left");
    if (personalLeft > 0) parts.add("Personal: $personalLeft pending");
    return parts.join(" • ");
  }

  NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  Future<void> _cancelRange(int startId, int endId) async {
    for (int i = startId; i <= endId; i++) {
      await _plugin.cancel(i);
    }
  }
}
