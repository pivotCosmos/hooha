import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
enum Gender { male, female }
class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  DateTime? _quitDate;
  String? _selectedJob;

  var _attendanceCount;
  var _consecutiveDays;
  var _isAttendanceCompleted;
  var _lastAttendanceDate;



  DateTime dateTime = DateTime.now(); // 사용자가 선택한 시간을 저장
  bool isNotificationEnabled = false; // 알림 활성화 여부
  int notificationId = 0; // 푸시 알림 ID
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final List<String> _genders = ['남성', '여성'];
  final List<bool> _isSelected = [false, false];
  
 
  

  @override
  void initState() {
    super.initState();
    initializeNotifications(); // 알림 설정 초기화
    _loadUserInformation();
  }

  Future<void> _loadUserInformation() async {

    final kakao.User user = await kakao.UserApi.instance.me();
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.id.toString());
    final userId = await userDocRef.get();
    print('MyPageUserId ::: $userId');
    print('userid: ${user.id}');

    if (userId != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.id.toString());
      final userData = await userDocRef.get();

      setState(() {
        _nameController.text = userData['displayName'] ?? '';
        _selectedGender = userData['gender'];
        _selectedJob = userData['job'];
        final quitDateMilliseconds = userData['quitDate'];
        _quitDate = quitDateMilliseconds != null
            ? DateTime.fromMillisecondsSinceEpoch(quitDateMilliseconds)
            : null;
      });
    }
  }

  Future<void> _saveUserInformation() async {
  final kakao.User user = await kakao.UserApi.instance.me();
  if (user.id != null) {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.id.toString());

    await userDocRef.update({
      'displayName': user.kakaoAccount?.profile?.nickname,
      'email': user.kakaoAccount?.email,
      'name': _nameController.text,
      'gender': _selectedGender == Gender.male ? 'male' : 'female',
      'quitDate': _quitDate != null ? _quitDate!.millisecondsSinceEpoch : null,
      'job': _selectedJob,
    });

    if (_attendanceCount != null) {
      await userDocRef.update({'attendanceCount': _attendanceCount});
    }

    if (_consecutiveDays != null) {
      await userDocRef.update({'consecutiveDays': _consecutiveDays});
    }

    if (_isAttendanceCompleted != null) {
      await userDocRef.update({'isAttendanceCompleted': _isAttendanceCompleted});
    }

    if (_lastAttendanceDate != null) {
      await userDocRef.update({
        'lastAttendanceDate': _lastAttendanceDate!.toIso8601String(),
      });
    }

    setState(() {
      _loadUserInformation();
    });
  }
}



  Future<void> _updateUserInformation() async {
  final kakao.User user = await kakao.UserApi.instance.me();
  final userId = user.id.toString();
  final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  await userDocRef.update({
    'displayName': _nameController.text,
    'gender': _selectedGender,
    'quitDate': _quitDate != null ? _quitDate!.millisecondsSinceEpoch : null,
    'job': _selectedJob,
  });

  setState(() {
    _loadUserInformation(); // 수정된 정보를 다시 불러와 UI 업데이트
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('정보가 업데이트되었습니다.')),
  );
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
    body:SingleChildScrollView(
      child: Padding(
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
                Text(
                  '직업',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        String? selectedJob = _selectedJob;
                        return AlertDialog(
                          title: Text('직업 선택'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile<String>(
                                title: const Text('직장인'),
                                value: '직장인',
                                groupValue: selectedJob,
                                onChanged: (String? value) {
                                  selectedJob = value;
                                },
                              ),
                              RadioListTile<String>(
                                title: const Text('학생'),
                                value: '학생',
                                groupValue: selectedJob,
                                onChanged: (String? value) {
                                  selectedJob = value;
                                },
                              ),
                              RadioListTile<String>(
                                title: const Text('주부'),
                                value: '주부',
                                groupValue: selectedJob,
                                onChanged: (String? value) {
                                  selectedJob = value;
                                },
                              ),
                              RadioListTile<String>(
                                title: const Text('군인'),
                                value: '군인',
                                groupValue: selectedJob,
                                onChanged: (String? value) {
                                  selectedJob = value;
                                },
                              ),
                              RadioListTile<String>(
                                title: const Text('무직'),
                                value: '무직',
                                groupValue: selectedJob,
                                onChanged: (String? value) {
                                  selectedJob = value;
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedJob = selectedJob!;
                                });
                                Navigator.pop(context);
                              },
                              child: Text('확인'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(_selectedJob != null ? _selectedJob! : '직업 선택'),
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
            tileColor: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: Colors.grey.shade400,
                width: 2.0,
              ),
            ),
            leading: Icon(Icons.notifications),
            title: Text('알림 설정'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSettingsPage()),
              );
            },
          ),
        ],
      ),
      ),
    ),
  );
}
}

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '알림 설정',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '매일 알림 받기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Switch(
                  value: true,
                  onChanged: (value) {
                    // 알림 활성화 여부 변경
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}