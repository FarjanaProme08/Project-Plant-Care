import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return; // Notifications not supported for web in this implementation

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
    debugPrint("NotificationService initialized");
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;

    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    debugPrint("Requested permissions");
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return;
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'plant_care_channel_id',
      'Plant Care Notifications',
      channelDescription: 'Notifications for plant watering and care tasks',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    debugPrint("Notification Scheduled: \$title for \$scheduledDate");
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(id: id);
    debugPrint("Notification \$id cancelled");
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancelAll();
    debugPrint("All notifications cancelled");
  }
}
