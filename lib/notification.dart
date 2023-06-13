import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
<<<<<<< HEAD
=======
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
>>>>>>> 9f761d9604313c721a935e097a2b416e43f0f044
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin noticePlugIn =
      FlutterLocalNotificationsPlugin();

<<<<<<< HEAD
  static init() async {
    AndroidInitializationSettings androidInitSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings iosInitSettings =
=======
  //알림 초기화
  static init() async {
    tz.initializeTimeZones();
    final timezoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    AndroidInitializationSettings androidInitSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings initializationSettingsDarwin =
>>>>>>> 9f761d9604313c721a935e097a2b416e43f0f044
        const DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);

    InitializationSettings initSettings = InitializationSettings(
<<<<<<< HEAD
        android: androidInitSettings, iOS: iosInitSettings);
=======
        android: androidInitSettings, iOS: initializationSettingsDarwin);
>>>>>>> 9f761d9604313c721a935e097a2b416e43f0f044

    await noticePlugIn.initialize(initSettings);
  }

<<<<<<< HEAD
=======
  //알림 발송 권한 부여(iOS)
>>>>>>> 9f761d9604313c721a935e097a2b416e43f0f044
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
<<<<<<< HEAD
    tz.initializeTimeZones();
=======
    //var now = tz.TZDateTime.now(tz.local);
>>>>>>> 9f761d9604313c721a935e097a2b416e43f0f044

    var androidDetails = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      priority: Priority.high,
      importance: Importance.max,
      color: Color.fromARGB(255, 255, 166, 0),
    );

    noticePlugIn.zonedSchedule(
<<<<<<< HEAD
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
=======
        1,
        'HOOHA 알림',
        '다시 담배를 피우면 나는 죽는다.',
        makeDate(10, 45, 0),
        // tz.TZDateTime(tz.local, now.year, now.month, now.day, now.hour,
        //     now.minute + 1, now.second),
        NotificationDetails(android: androidDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  static makeDate(hour, minute, second) {
    var now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute, second);
    if (when.isBefore(now)) {
      return when.add(const Duration(days: 1));
    } else {
      return when;
    }
  }
}



/*import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin noticePlugIn =
      FlutterLocalNotificationsPlugin();

  //알림 초기화
  static init() async {
    tz.initializeTimeZones();
    final timezoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    AndroidInitializationSettings androidInitSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings initializationSettingsDarwin =
        const DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);

    InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings, iOS: initializationSettingsDarwin);

    await noticePlugIn.initialize(initSettings);
  }

  //알림 발송 권한 부여(iOS)
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
    //var now = tz.TZDateTime.now(tz.local);

    var androidDetails = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      priority: Priority.high,
      importance: Importance.max,
      color: Color.fromARGB(255, 255, 166, 0),
    );

    noticePlugIn.zonedSchedule(
        1,
        'HOOHA 알림',
        '다시 담배를 피우면 나는 죽는다.',
        makeDate(9, 54, 0),
        // tz.TZDateTime(tz.local, now.year, now.month, now.day, now.hour,
        //     now.minute + 1, now.second),
        NotificationDetails(android: androidDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  static makeDate(hour, minute, second) {
    var now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute, second);
    if (when.isBefore(now)) {
      return when.add(const Duration(days: 1));
    } else {
      return when;
    }
  }
}
*/
>>>>>>> 9f761d9604313c721a935e097a2b416e43f0f044
