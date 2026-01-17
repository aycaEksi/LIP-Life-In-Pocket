import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../repositories/focus_repository.dart';
import '../models/focus_day_model.dart';
import '../models/personal_reminder_model.dart';
import 'api_service.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'focus_reminders';
  static const String _channelName = 'Focus reminders';
  
  static const String _moodChannelId = 'mood_insights';
  static const String _moodChannelName = 'Mood Insights';
  
  static const String _waterChannelId = 'water_reminders';
  static const String _waterChannelName = 'Su İçme Hatırlatıcısı';

  Future<void> init() async {
    tz.initializeTimeZones();
    
    // Windows/Linux/macOS'ta flutter_timezone desteklenmiyor, default timezone kullan
    if (Platform.isAndroid || Platform.isIOS) {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } else {
      // Desktop platformlarda UTC veya local timezone kullan
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    }

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

      // Mood insights channel
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _moodChannelId,
          _moodChannelName,
          description: 'AI-powered insights about your mood every 2 hours.',
          importance: Importance.high,
        ),
      );

      // Water reminder channel
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _waterChannelId,
          _waterChannelName,
          description: 'Günde 5 kez su içmenizi hatırlatır.',
          importance: Importance.high,
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

  // ==================== MOOD INSIGHTS NOTIFICATIONS ====================

  /// Mood kaydedildikten sonra AI yorumuyla anında bildirim gönder
  Future<void> sendMoodInsightNotification({
    required int energy,
    required int happiness,
    required int stress,
    String? note,
  }) async {
    try {
      // AI'dan yorum al
      final insight = await _getMoodInsightFromAI(
        energy: energy,
        happiness: happiness,
        stress: stress,
        note: note,
      );

      // Bildirimi hemen göster
      await _plugin.show(
        7999, // Mood insight immediate notification ID
        "💭 Ruh Haliniz Hakkında",
        insight,
        _moodDetails(),
      );
    } catch (e) {
      print('Mood insight notification error: $e');
    }
  }

  /// AI'dan mood yorumu al
  Future<String> _getMoodInsightFromAI({
    required int energy,
    required int happiness,
    required int stress,
    String? note,
  }) async {
    try {
      final response = await ApiService.instance.getMoodInsight(
        energy: energy,
        happiness: happiness,
        stress: stress,
        note: note,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['insight'] ?? 'Ruh halinizi kaydettik! 🌈';
      }
    } catch (e) {
      print('AI mood insight error: $e');
    }

    // Fallback mesajlar
    final fallbacks = [
      'Harika! Ruh halinizi kaydettik. Günün geri kalanı da güzel geçsin! 🌟',
      'Not aldık! Kendinize iyi bakın ve olumlu düşünün 💪',
      'Teşekkürler! Duygularınızı paylaştığınız için 🙏',
      'Kaydedildi! Her gün daha iyi hissetmeniz dileğiyle 🌈',
    ];
    return fallbacks[DateTime.now().second % fallbacks.length];
  }

  NotificationDetails _moodDetails() {
    const android = AndroidNotificationDetails(
      _moodChannelId,
      _moodChannelName,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(android: android, iOS: ios);
  }

  /// Her 2 saatte bir son mood verilerini AI'a yorumlatıp bildirim gönder
  Future<void> scheduleMoodInsights() async {
    // Önceki periyodik bildirimleri iptal et
    await _cancelRange(8000, 8100);

    final now = tz.TZDateTime.now(tz.local);
    int notificationId = 8000;

    // 2 saatte bir bildirim zamanla (24 saat için 12 bildirim)
    for (int i = 1; i <= 12; i++) {
      final scheduledTime = now.add(Duration(hours: i * 2));

      await _plugin.zonedSchedule(
        notificationId++,
        "💭 Ruh Haliniz Hakkında",
        "AI yorumunuz hazırlanıyor...",
        scheduledTime,
        _moodDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'mood_insight_periodic',
      );
    }

    // İlk bildirimi hemen gönder
    await _sendPeriodicMoodInsight();
  }

  /// Periyodik mood insight bildirimi gönder
  Future<void> _sendPeriodicMoodInsight() async {
    try {
      // Son kaydedilen mood verisini al
      final response = await ApiService.instance.getLatestMood();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mood = data['mood'];
        
        if (mood != null) {
          final energy = mood['energy'] ?? 5;
          final happiness = mood['happiness'] ?? 5;
          final stress = mood['stress'] ?? 5;
          final note = mood['note'];

          // AI yorumu al
          final insight = await _getMoodInsightFromAI(
            energy: energy,
            happiness: happiness,
            stress: stress,
            note: note,
          );

          // Bildirimi güncelle (önceki "hazırlanıyor" mesajını değiştir)
          await _plugin.show(
            8000,
            "💭 Ruh Haliniz Hakkında",
            insight,
            _moodDetails(),
          );
        }
      }
    } catch (e) {
      print('Periodic mood insight error: $e');
    }
  }

  // ==================== WATER REMINDERS ====================

  /// Her gün sabit saatlerde su içme hatırlatıcısı (09:00, 12:00, 15:00, 18:00, 21:00)
  Future<void> scheduleWaterReminders() async {
    // Önceki su bildirimleri iptal et
    await _cancelRange(7000, 7010);

    final now = tz.TZDateTime.now(tz.local);
    final waterTimes = [9, 12, 15, 18, 21]; // Saat dilimleri
    int notificationId = 7000;

    for (final hour in waterTimes) {
      // Bugün için zamanı hesapla
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        0,
      );

      // Eğer saat geçmişse yarın için zamanla
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        notificationId++,
        '💧 Su İçmeyi Unutma!',
        'Sağlığınız için su içme zamanı! 💙',
        scheduledTime,
        _waterDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Her gün aynı saatte tekrarla
      );

      print('💧 Su hatırlatıcısı zamanlandı: ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}');
    }
  }

  NotificationDetails _waterDetails() {
    const android = AndroidNotificationDetails(
      _waterChannelId,
      _waterChannelName,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(android: android, iOS: ios);
  }
}
