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
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;
  DateTime? _quitDate;

  DateTime dateTime = DateTime.now(); // 사용자가 선택한 시간을 저장

  @override
  void initState() {
    super.initState();
    _loadUserInformation();
  }

  Future<void> _loadUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = sharedPreferences.getString('name') ?? '';
      _isMaleSelected = sharedPreferences.getBool('isMaleSelected') ?? false;
      _isFemaleSelected =
          sharedPreferences.getBool('isFemaleSelected') ?? false;
      final quitDateMilliseconds = sharedPreferences.getInt('quitDate');
      _quitDate = quitDateMilliseconds != null
          ? DateTime.fromMillisecondsSinceEpoch(quitDateMilliseconds)
          : null;
    });
  }

  Future<void> _saveUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('name', _nameController.text);
    sharedPreferences.setBool('isMaleSelected', _isMaleSelected);
    sharedPreferences.setBool('isFemaleSelected', _isFemaleSelected);
    if (_quitDate != null) {
      sharedPreferences.setInt('quitDate', _quitDate!.millisecondsSinceEpoch);
    } else {
      sharedPreferences.remove('quitDate');
    }
  }

  void _updateUserInformation() {
    // 사용자 정보 업데이트를 위한 필요한 동작 수행
    // 예를 들어, 서버에서 사용자 정보를 업데이트하기 위해 API 호출
    // 업데이트된 값은 _nameController.text, _selectedGender, _quitDate를 사용하여 액세스할 수 있음
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
        automaticallyImplyLeading: false, // 뒤로가기 버튼 비활성화
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
                        isSelected: [_isMaleSelected, _isFemaleSelected],
                        onPressed: (int index) {
                          setState(() {
                            if (index == 0) {
                              _isMaleSelected = !_isMaleSelected;
                              _isFemaleSelected = false;
                            } else if (index == 1) {
                              _isMaleSelected = false;
                              _isFemaleSelected = !_isFemaleSelected;
                            }
                          });
                        },
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
