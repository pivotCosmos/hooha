import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin noticePlugIn =
      FlutterLocalNotificationsPlugin();

  static init() async {
    AndroidInitializationSettings androidInitSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings iosInitSettings =
        const DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);

    InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings, iOS: iosInitSettings);

    await noticePlugIn.initialize(initSettings);
  }

  static requestNotificationPermission() {
    noticePlugIn
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidNoticeDetails =
        AndroidNotificationDetails('channel id', 'channel name',
            channelDescription: 'channel description',
            importance: Importance.max,
            priority: Priority.max,
            showWhen: false);

    const NotificationDetails noticeDetails = NotificationDetails(
        android: androidNoticeDetails,
        iOS: DarwinNotificationDetails(badgeNumber: 1));

    await noticePlugIn.show(
        0, 'HOOHA 알림', '금연 성공하면 1000만원 받는다!', noticeDetails);
  }

  static showNotification2() async {
    tz.initializeTimeZones();

    var androidDetails = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      priority: Priority.high,
      importance: Importance.max,
      color: Color.fromARGB(255, 255, 166, 0),
    );

    noticePlugIn.zonedSchedule(
        2,
        'HOOHA 알림',
        '다시 담배를 피우면 나는 죽는다.',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
        NotificationDetails(android: androidDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Time alarmTime = const Time(11, 30, 00);

  tz.TZDateTime scheduledDaily(Time alarmTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
        now.day, alarmTime.hour, alarmTime.minute);
    scheduledDate = scheduledDate.add(const Duration(days: 1));
    return scheduledDate;
  }

  Future<void> dailyNotification(BuildContext context, Time alarmTime) async {
    var androidDetails = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      priority: Priority.high,
      importance: Importance.high,
    );

    await noticePlugIn.zonedSchedule(2, 'HOOHA 알림', '다시 담배를 피우면 나는 죽는다.',
        scheduledDaily(alarmTime), NotificationDetails(android: androidDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }
}
