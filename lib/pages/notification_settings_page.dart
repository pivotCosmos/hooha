import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsPage extends StatefulWidget {
  NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final String notificationTimeKey = 'notificationTime'; // SharedPreferences 키
  DateTime dateTime = DateTime.now();
  DateTime dateTime2 = DateTime.now();
  bool isNotificationEnabled = false; // 알림 활성화 여부
  bool isNotificationEnabled2 = false; // 알림 활성화 여부
  int notificationId = 0; // 푸시 알림 ID
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController _controller = TextEditingController();
  late SharedPreferences prefs; // 추가: SharedPreferences 인스턴스
  List<String> notificationHistory = [];

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    loadNotificationSettings(); // 저장된 알림 설정 값 및 시간 로드
  }

  // 추가: 저장된 알림 설정 값 및 시간 로드
  Future<void> loadNotificationSettings() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isNotificationEnabled = prefs.getBool('notificationEnabled') ?? false;
      isNotificationEnabled2 = prefs.getBool('notificationEnabled2') ?? false;
      // 저장된 시간 값을 가져옴
      dateTime2 = DateTime.parse(
          prefs.getString(notificationTimeKey) ?? DateTime.now().toString());
      dateTime = DateTime.parse(
          prefs.getString('dateTime') ?? DateTime.now().toString());
    });
  }

  // 추가: 알림 설정 값 및 시간 저장
  Future<void> saveNotificationSettings() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationEnabled', isNotificationEnabled);
    prefs.setBool('notificationEnabled2', isNotificationEnabled2);
    // dateTime2 값을 저장
    prefs.setString(notificationTimeKey, dateTime2.toString());
    prefs.setString('dateTime', dateTime.toString());
  }

  void toggleNotification(bool value) {
    setState(() {
      isNotificationEnabled = value;
      if (isNotificationEnabled) {
        scheduleNotification();
      } else {
        cancelNotification();
      }
      saveNotificationSettings(); // 추가: 알림 설정 값 저장
    });
  }

  void toggleNotification2(bool value) {
    setState(() {
      isNotificationEnabled2 = value;
      if (isNotificationEnabled) {
        scheduleNotification();
      } else {
        cancelNotification();
      }
      saveNotificationSettings(); // 추가: 알림 설정 값 저장
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
    var nextDay = scheduledDate.add(const Duration(minutes: 0));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '로컬 푸시 알림',
      '출석체크 설정한 시간입니다!',
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('알림'), //알림 페이지의 상단바에 표시될 타이틀
      ),
      body: Material(
        child: Container(
          margin: const EdgeInsets.all(16), // 테두리와 위젯 사이에 간격을 줍니다.
          padding: const EdgeInsets.all(16), // 테두리 안의 위젯들에 간격을 줍니다.
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey), // 테두리 색상을 지정합니다.
            borderRadius: BorderRadius.circular(8), // 테두리의 둥근 정도를 조절합니다.
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '알림',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 20), // 여백 추가
                  const SizedBox(child: Text('금연여부 체크 알림')),
                  const SizedBox(width: 20), // 여백 추가
                  Flexible(
                    child: OutlinedButton(
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) => SizedBox(
                            height: 250,
                            child: CupertinoDatePicker(
                              backgroundColor: Colors.white,
                              initialDateTime: dateTime2,
                              onDateTimeChanged: (DateTime newTime) {
                                setState(() {
                                  dateTime2 = newTime;
                                  scheduleNotification(); // 새로운 시간으로 알림 예약
                                });
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
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  //SizedBox(width: 16),
                  SizedBox(
                    height: 36,
                    width: 100,
                    child: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: isNotificationEnabled2,
                        onChanged: toggleNotification2,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8), // 첫 번째 간격
              Divider(color: Colors.grey), // 연한 회색 줄
              SizedBox(height: 8), // 두 번째 간격
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 20), // 여백 추가
                  const SizedBox(child: Text('격려 알림 시작')),
                  const SizedBox(width: 44), // 여백 추가
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
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
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  //SizedBox(width: 16),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15), // contentPadding 내부 여백조정
                  child: TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '알림 메세지를 입력하세요'),
                    controller: _controller,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 135,
                    child: ElevatedButton(
                        onPressed: showNotification_30M,
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Set the border radius value here
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 217, 202,
                                  245)), // Set the button color to purple
                        ),
                        child: const Text(
                          "30분",
                          style:
                              TextStyle(color: Color.fromARGB(255, 56, 56, 56)),
                        )),
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    width: 135,
                    child: ElevatedButton(
                        onPressed: showNotification_1H,
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Set the border radius value here
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 217, 202,
                                  245)), // Set the button color to purple
                        ),
                        child: const Text(
                          "1시간",
                          style:
                              TextStyle(color: Color.fromARGB(255, 56, 56, 56)),
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
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Set the border radius value here
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 217, 202,
                                  245)), // Set the button color to purple
                        ),
                        child: const Text(
                          "1시간 30분",
                          style:
                              TextStyle(color: Color.fromARGB(255, 56, 56, 56)),
                        )),
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    width: 135,
                    child: ElevatedButton(
                        onPressed: showNotification_2H,
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Set the border radius value here
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 217, 202,
                                  245)), // Set the button color to purple
                        ),
                        child: const Text(
                          "2시간",
                          style:
                              TextStyle(color: Color.fromARGB(255, 56, 56, 56)),
                        )),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
