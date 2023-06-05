import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_settings_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  DateTime? _quitDate;

  DateTime dateTime = DateTime.now(); // 사용자가 선택한 시간을 저장
  bool isNotificationEnabled = false; // 알림 활성화 여부
  int notificationId = 0; // 푸시 알림 ID
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications(); // 알림 설정 초기화
    _loadUserInformation();
  }

  Future<void> _loadUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = sharedPreferences.getString('name') ?? '';
      _selectedGender = sharedPreferences.getString('gender');
      final quitDateMilliseconds = sharedPreferences.getInt('quitDate');
      _quitDate = quitDateMilliseconds != null
          ? DateTime.fromMillisecondsSinceEpoch(quitDateMilliseconds)
          : null;
    });
  }

  Future<void> _saveUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('name', _nameController.text);
    sharedPreferences.setString('gender', _selectedGender ?? '');
    if (_quitDate != null) {
      sharedPreferences.setInt('quitDate', _quitDate!.millisecondsSinceEpoch);
    } else {
      sharedPreferences.remove('quitDate');
    }
  }

  void _updateUserInformation() {
    // Perform the necessary actions to update user information
    // For example, make an API call to update the user information on the server
    // You can access the updated values using _nameController.text, _selectedGender, _quitDate
  }

  void toggleNotification(bool value) {
    setState(() {
      isNotificationEnabled = value;
      if (isNotificationEnabled) {
        scheduleNotification(); // 알림이 활성화되면 알림 예약
      } else {
        cancelNotification(); // 알림이 비활성화되면 알림 취소
      }
    });
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<void> initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Android 초기화 설정
    var initializationSettingsIOS =
        DarwinInitializationSettings(); // iOS 초기화 설정
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin
        .initialize(initializationSettings); // 알림 플러그인 초기화

    tz.initializeTimeZones(); // 시간대 초기화
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
        priority: Priority.high); // Android 알림 설정

    var iOSPlatformChannelSpecifics = DarwinNotificationDetails(); // iOS 알림 설정
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    var scheduledDate =
        tz.TZDateTime.from(dateTime, tz.local); // 사용자가 설정한 시간을 가져온다.

    // 다음 날의 동일한 시간으로 설정
    var nextDay = scheduledDate.add(const Duration(days: 1));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // 알림 ID
      'HOOHA 알림', // 알림 제목
      '출석체크 할 시간입니다!',
      nextDay, // 예약 시간
      platformChannelSpecifics, // 알림 설정
      //androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '매일 알림',
      //androidAllowWhileIdle: true,
      //repeatInterval: RepeatInterval.daily,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: 'male',
                  child: Text('남성'),
                ),
                DropdownMenuItem(
                  value: 'female',
                  child: Text('여성'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: '성별',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _quitDate ?? DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _quitDate = pickedDate;
                  });
                }
              },
              child: Text(
                _quitDate != null
                    ? '금연 시작일: ${_quitDate!.toString().split(' ')[0]}'
                    : '금연 시작 날짜',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _saveUserInformation();
                _updateUserInformation();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('정보가 저장되었습니다.')),
                );
              },
              child: const Text('저장'),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              title: Text('알림 설정'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationSettingsPage()),
                );
              },
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
          ],
        ),
      ),
    );
  }
}
