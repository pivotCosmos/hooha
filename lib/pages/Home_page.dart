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
  int _consecutiveDays = 0;
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
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.id.toString());
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
          _consecutiveDays = userData['consecutiveDays'] ?? 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = 'assets/images/5th.png'; // 기본 이미지 경로

    // 연속 출석일에 따라 이미지 경로 변경
    switch (_consecutiveDays) {
      case 1:
        imagePath = 'assets/images/5th.png';
        break;
      case 2:
        imagePath = 'assets/images/4th.png';
        break;
      case 3:
        imagePath = 'assets/images/3rd.png';
        break;
      case 4:
        imagePath = 'assets/images/2nd.png';
        break;
      case 5:
        imagePath = 'assets/images/1th.png';
        break;
      default:
        imagePath = 'assets/images/3rd.png';
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white, // 흰색으로 변경
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade100, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors
                      .grey.shade100, // 텍스트를 감싸는 테두리밖과 전체를 감싼 테두리 사이를 채우는 색상
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOME',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50.0),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(220),
                        child: Image.asset(
                          imagePath,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade100, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white, // 흰색으로 변경
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person),
                              SizedBox(width: 8.0),
                              Text(
                                '$_name 님!',
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '후하를 통해 금연에 성공하세요',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade100, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white, // 흰색으로 변경
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 8.0),
                              Text(
                                '금연 시작일',
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '${_quitDate != null ? _quitDate.toString().split(' ')[0] : 'Not set'}',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade100, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white, // 흰색으로 변경
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.schedule),
                              SizedBox(width: 8.0),
                              Text(
                                '금연 기간',
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '금연 $_quitDays 일 째',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade100, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white, // 흰색으로 변경
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle),
                              SizedBox(width: 8.0),
                              Text(
                                '연속 출석',
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '$_consecutiveDays 일 동안 출석 중입니다.',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade100, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white, // 흰색으로 변경
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.attach_money),
                              SizedBox(width: 8.0),
                              Text(
                                '절약한 금액',
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '$_money원 절약 중이에요.',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
