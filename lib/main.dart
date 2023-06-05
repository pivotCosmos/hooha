import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './pages/navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// ignore: unused_import
import 'package:bubble/bubble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/navigation.dart';
import 'pages/InputInfo_Page.dart';

// ignore: non_constant_identifier_names
String OPENAI_API_KEY = dotenv.env['OPEN_AI_API_KEY']!;
// ignore: constant_identifier_names
const String MODEL_ID = 'gpt-3.5-turbo';

/// Cloud Firestore init
FirebaseFirestore db = FirebaseFirestore.instance;

void main() async {
  await dotenv.load(fileName: 'assets/images/.env');
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HOOHA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: checkUserInformationExists(), // 사용자 정보 존재 여부 확인
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return NavigationExample(); // 사용자 정보가 존재하면 NavigationExample으로 이동
          } else {
            return InputInfoPage(onInfoEntered: () {
              // 정보 입력이 완료되면 NavigationExample으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NavigationExample()),
              );
            });
          }
        },
      ),
    );
  }

  Future<bool> checkUserInformationExists() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final name = sharedPreferences.getString('name');
    final gender = sharedPreferences.getString('gender');
    final quitDate = sharedPreferences.getInt('quitDate');

    // 사용자 정보가 모두 존재하는지 확인
    if (name != null && gender != null && quitDate != null) {
      return true; // 사용자 정보가 존재하면 true 반환
    } else {
      return false; // 사용자 정보가 존재하지 않으면 false 반환
    }
  }
}
