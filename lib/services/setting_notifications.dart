import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Yêu cầu quyền truy cập thông báo
    var status = await Permission.notification.request();
    if (status.isGranted) {
      // Quyền đã được cấp, tiếp tục khởi tạo thông báo
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );
    } else {
      // Quyền không được cấp, tắt ứng dụng
      exit(0);
    }
  }

  Future<void> scheduleNotification(int id, String title, String body,
      DateTime scheduledDate) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'id',
          'name',
          channelDescription: 'description',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> schedulePreNotifications(int id, String title, String body,
      DateTime scheduledDate) async {
    if (scheduledDate.isAfter(DateTime.now())) {
      DateTime sevenDaysBefore = scheduledDate.subtract(Duration(days: 7));
      if (sevenDaysBefore.isAfter(DateTime.now())) {
        await scheduleNotification(id + 1, title,
            'Thông báo trước 7 ngày: $body', sevenDaysBefore);
      }

      DateTime threeDaysBefore = scheduledDate.subtract(Duration(days: 3));
      if (threeDaysBefore.isAfter(DateTime.now())) {
        await scheduleNotification(id + 2, title,
            'Thông báo trước 3 ngày: $body', threeDaysBefore);
      }

      DateTime oneDayBefore = scheduledDate.subtract(Duration(days: 1));
      if (oneDayBefore.isAfter(DateTime.now())) {
        await scheduleNotification(id + 3, title,
            'Thông báo trước 1 ngày: $body', oneDayBefore);
      }

      DateTime twelveHoursBefore = scheduledDate.subtract(Duration(hours: 12));
      if (twelveHoursBefore.isAfter(DateTime.now())) {
        await scheduleNotification(id + 4, title,
            'Thông báo trước 12 giờ: $body', twelveHoursBefore);
      }
      DateTime oneminutesbefore = scheduledDate.subtract(Duration(minutes: 1));
      if (oneminutesbefore.isAfter(DateTime.now())) {
        await scheduleNotification(id + 5, title,
            'Thông báo trước 1 phut: $body', oneminutesbefore);
      }
    }
  }
}
