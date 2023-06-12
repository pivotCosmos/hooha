import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Calendar_Page.dart' as calendar;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  
  String _name = '';
  int? _checkdays = 0;
  DateTime? _quitDate;
  int _quitDays = 0;
  final int _consecutiveDays = 0;
  int _money = 0;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((value) {
      _loadUserInformation();
      //_loadAttendanceCount();
    });
  }

  Future<void> _loadUserInformation() async {
    final kakao.User user = await kakao.UserApi.instance.me();
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.id.toString());
    final userSnapshot = await userDocRef.get();
    print('userid: ${user.id}');
    if (userSnapshot.exists) {
      final userData = userSnapshot.data();
      if (userData != null) {
        setState(() {
          _name = userData['name'] ?? '';
          _checkdays = userData['attendanceCount'] as int?; // 수정된 부분
          final quitDateTimestamp = userData['quitDate'];
          final int quitDateTimestampInt =
              quitDateTimestamp != null ? quitDateTimestamp : 0;
          _quitDate = quitDateTimestampInt != 0
              ? DateTime.fromMillisecondsSinceEpoch(quitDateTimestampInt)
              : null;

          final now = DateTime.now();
          if (_quitDate != null) {
            _quitDays = now.difference(_quitDate!).inDays;
          }
          _money = _quitDays * 4500;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    String imagePath = 'assets/images/3rd.png'; // 기본 이미지 경로

    // 연속 출석일에 따라 이미지 경로 변경
    if (_consecutiveDays == 1) {
      imagePath = 'assets/images/2nd.png';
    } else if (_consecutiveDays >= 2) {
      imagePath = 'assets/images/1st.png';
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_name 님! 오늘도 방문해 주셨군요!',
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              '금연 시작일: ${_quitDate != null ? _quitDate.toString().split(' ')[0] : 'Not set'}',
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              '금연 $_quitDays 일 째',
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              '$_checkdays 일 동안 출석 중입니다.',
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              '$_money원 절약 중이에요.',
              style: const TextStyle(fontSize: 18.0),
            ),
            
          
            Center(
              child: Image.asset(
                imagePath,
                width: 250,
                height: 250,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
