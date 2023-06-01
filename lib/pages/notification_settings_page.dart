import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationSettingsPage extends StatefulWidget {
  NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  DateTime dateTime = DateTime.now();
  DateTime dateTime2 = DateTime.now();
  bool isNotificationEnabled = false; // 알림 활성화 여부
  int notificationId = 0; // 푸시 알림 ID
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  void toggleNotification(bool value) {
    setState(() {
      isNotificationEnabled = value;
      if (isNotificationEnabled) {
        scheduleNotification();
      } else {
        cancelNotification();
      }
    });
  }

  void toggleNotification2(bool value) {
    setState(() {
      isNotificationEnabled = value;
      if (isNotificationEnabled) {
        scheduleNotification();
      } else {
        cancelNotification();
      }
    });
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<void> initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    tz.initializeTimeZones();
  }

  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
  }

  Future<void> scheduleNotification() async {
    if (!isNotificationEnabled) {
      return; // 알림이 꺼져있을 때는 예약하지 않음
    }
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_id', 'channel_name',
        channelDescription: 'channel_description',
        importance: Importance.high,
        priority: Priority.high);

    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    var scheduledDate =
        tz.TZDateTime.from(dateTime2, tz.local); // 사용자가 설정한 시간을 가져온다.

    // 다음 날의 동일한 시간으로 설정
    var nextDay = scheduledDate.add(const Duration(minutes: 1));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '로컬 푸시 알림',
      '설정한 시간입니다!',
      nextDay,
      platformChannelSpecifics,
      //androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '매일 알림',
      //androidAllowWhileIdle: true,
      //repeatInterval: RepeatInterval.daily,
    );
  }

  //30분마다 알림 발송
  Future<void> showNotification_30M() async {
    var scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
    if (!isNotificationEnabled) {
      return;
    }

    var androidDetails = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      priority: Priority.high,
      importance: Importance.max,
      color: Color.fromARGB(255, 255, 166, 0),
    );

    flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        'HOOHA 푸쉬 알림(30분)',
        _controller.text,
        scheduledDate.add(const Duration(minutes: 30)),
        NotificationDetails(android: androidDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  //1시간마다 알림 발송
  Future<void> showNotification_1H() async {
    var scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
    if (!isNotificationEnabled) {
      return;
    }

    var androidDetails = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      priority: Priority.high,
      importance: Importance.max,
      color: Color.fromARGB(255, 255, 166, 0),
    );

    flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        'HOOHA 푸쉬 알림(1시간)',
        _controller.text,
        scheduledDate.add(const Duration(hours: 1)),
        NotificationDetails(android: androidDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  //1시간 30분마다 알림 발송
  Future<void> showNotification_90M() async {
    var scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
    if (!isNotificationEnabled) {
      return;
    }

    var androidDetails = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      priority: Priority.high,
      importance: Importance.max,
      color: Color.fromARGB(255, 255, 166, 0),
    );

    flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        'HOOHA 푸쉬 알림(1시간 30분)',
        _controller.text,
        scheduledDate.add(const Duration(hours: 1, minutes: 30)),
        NotificationDetails(android: androidDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  //2시간마다 알림 발송
  Future<void> showNotification_2H() async {
    var scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
    if (!isNotificationEnabled) {
      return;
    }

    var androidDetails = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      priority: Priority.high,
      importance: Importance.max,
      color: Color.fromARGB(255, 255, 166, 0),
    );

    flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        'HOOHA 푸쉬 알림(2시간)',
        _controller.text,
        scheduledDate.add(const Duration(hours: 2)),
        NotificationDetails(android: androidDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'), //알림 페이지의 상단바에 표시될 타이틀
      ),
      body: Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) => SizedBox(
                          height: 250,
                          child: CupertinoDatePicker(
                            backgroundColor: Colors.white,
                            initialDateTime: dateTime2,
                            onDateTimeChanged: (DateTime newTime) {
                              setState(() => dateTime2 = newTime);
                            },
                            use24hFormat: true,
                            mode: CupertinoDatePickerMode.time,
                          ),
                        ),
                      ).then((value) {
                        scheduleNotification();
                      });
                    },
                    child: Text(
                      '${dateTime2.hour}시 ${dateTime2.minute}분',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  height: 36,
                  width: 100,
                  child: Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: isNotificationEnabled,
                      onChanged: toggleNotification2,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) => SizedBox(
                          height: 250,
                          child: CupertinoDatePicker(
                            backgroundColor: Colors.white,
                            initialDateTime: dateTime,
                            onDateTimeChanged: (DateTime newTime) {
                              setState(() => dateTime = newTime);
                            },
                            use24hFormat: true,
                            mode: CupertinoDatePickerMode.time,
                          ),
                        ),
                      ).then((value) {
                        scheduleNotification();
                      });
                    },
                    child: Text(
                      '${dateTime.hour}시 ${dateTime.minute}분',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  height: 36,
                  width: 100,
                  child: Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: isNotificationEnabled,
                      onChanged: toggleNotification,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(8),
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: '알림 메세지 입력'),
                controller: _controller,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 135,
                  child: ElevatedButton(
                      onPressed: showNotification_30M,
                      child: const Text(
                        "30분",
                        style: TextStyle(color: Colors.black),
                      )),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 135,
                  child: ElevatedButton(
                      onPressed: showNotification_1H,
                      child: const Text(
                        "1시간",
                        style: TextStyle(color: Colors.black),
                      )),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 135,
                  child: ElevatedButton(
                      onPressed: showNotification_90M,
                      child: const Text(
                        "1시간 30분",
                        style: TextStyle(color: Colors.black),
                      )),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 135,
                  child: ElevatedButton(
                      onPressed: showNotification_2H,
                      child: const Text(
                        "2시간",
                        style: TextStyle(color: Colors.black),
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
