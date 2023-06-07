// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
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
  String? _selectedJob;

  DateTime dateTime = DateTime.now(); // 사용자가 선택한 시간을 저장
  bool isNotificationEnabled = false; // 알림 활성화 여부
  int notificationId = 0; // 푸시 알림 ID
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<String> _genders = ['남성', '여성'];
  List<bool> _isSelected = [false, false];

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
      _selectedJob = sharedPreferences.getString('job');
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
    sharedPreferences.setString('job', _selectedJob ?? '');
    if (_quitDate != null) {
      sharedPreferences.setInt('quitDate', _quitDate!.millisecondsSinceEpoch);
    } else {
      sharedPreferences.remove('quitDate');
    }
  }

  Future<void> _updateUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final userId = sharedPreferences.getString('userId');

    if (userId != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await userDocRef.update({
        'displayName': _nameController.text,
        'gender': _selectedGender,
        'quitDate':
            _quitDate != null ? _quitDate!.millisecondsSinceEpoch : null,
        'job': _selectedJob,
      });
      setState(() {
        // 사용자 정보가 업데이트되었으므로 상태를 갱신합니다.
        sharedPreferences.setString('name', _nameController.text);
        sharedPreferences.setString('gender', _selectedGender ?? '');
        sharedPreferences.setString('job', _selectedJob ?? '');
        if (_quitDate != null) {
          sharedPreferences.setInt(
              'quitDate', _quitDate!.millisecondsSinceEpoch);
        } else {
          sharedPreferences.remove('quitDate');
        }
      });
    }
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
    var initializationSettingsAndroid = const AndroidInitializationSettings(
        '@mipmap/ic_launcher'); // Android 초기화 설정

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

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
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'channel_id', 'channel_name',
        channelDescription: 'channel_description',
        importance: Importance.high,
        priority: Priority.high); // Android 알림 설정

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
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

  void _selectGender(int index) {
    setState(() {
      for (int i = 0; i < _isSelected.length; i++) {
        _isSelected[i] = (i == index);
      }
      _selectedGender = _isSelected[index] ? _genders[index] : null;
    });
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
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내정보',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '이름'),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '성별',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      ToggleButtons(
                        isSelected: _isSelected,
                        onPressed: _selectGender,
                        children: [
                          Text('남성'),
                          Text('여성'),
                        ],
                      ),
                    ],
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
                      // 토글 버튼 상태에 따라 선택된 성별 설정
                      setState(() {
                        _selectedGender = _isSelected[0]
                            ? _genders[0]
                            : _isSelected[1]
                                ? _genders[1]
                                : null;
                      });
                    },
                    child: const Text('저장'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              tileColor: Colors.grey.shade50, // 타일의 배경색을 설정할 수 있습니다.
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // 테두리의 모서리를 둥글게 만듭니다.
                side: BorderSide(
                    color: Colors.grey.shade400,
                    width: 2.0), // 테두리의 색상과 두께를 설정합니다.
              ),
              leading: Icon(Icons.notifications), // 아이콘 추가
              title: Text('알림 설정'),
              trailing: Icon(Icons.chevron_right), // 맨 오른쪽에 화살표 아이콘 추가
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationSettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
      /*body: Padding(
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
                  value: '남자',
                  child: Text('남성'),
                ),
                DropdownMenuItem(
                  value: '여자',
                  child: Text('여성'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: '성별',
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedJob,
              onChanged: (value) {
                setState(() {
                  _selectedJob = value;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: '직장인들',
                  child: Text('직장인'),
                ),
                DropdownMenuItem(
                  value: '학생들',
                  child: Text('학생'),
                ),
                DropdownMenuItem(
                  value: '주부들',
                  child: Text('주부'),
                ),
                DropdownMenuItem(
                  value: '군인들',
                  child: Text('군인'),
                ),
                DropdownMenuItem(
                  value: '무직들',
                  child: Text('무직'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: '직업',
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _quitDate != null
                        ? '금연 시작일: ${_quitDate!.toString().substring(0, 10)}'
                        : '금연 시작일을 설정해주세요.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _quitDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _quitDate = selectedDate;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: const Text('출석체크 알림 설정'),
              value: isNotificationEnabled,
              onChanged: toggleNotification,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _saveUserInformation();
          await _updateUserInformation();
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}*/
