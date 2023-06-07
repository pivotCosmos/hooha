import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooha/pages/Home_page.dart';
import '/kakao_login.dart';
import '/main_view_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: unused_import
import 'package:bubble/bubble.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/navigation.dart';
import 'pages/InputInfo_Page.dart';
import 'pages/Login_Page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: non_constant_identifier_names
String OPENAI_API_KEY = dotenv.env['OPEN_AI_API_KEY']!;
// ignore: constant_identifier_names
const String MODEL_ID = 'gpt-3.5-turbo';

/// Cloud Firestore init
FirebaseFirestore db = FirebaseFirestore.instance;

void main() async {
  await dotenv.load(fileName: 'assets/images/.env');
  //임의로 로그인 관련 기능 전부 주석처리함 로그인기능하려면 주석 풀고
  //밑에 @override 아래 위젯부분 지우면 됨

  /* WidgetsFlutterBinding.ensureInitialized();
  kakao.KakaoSdk.init(nativeAppKey: 'f4797bdadfc6cd9c0ec4bfd879d8337b');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform); // Firebase 초기화

  // 로그아웃 처리
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedOut = prefs.getBool('isLoggedOut') ?? false;
  if (isLoggedOut) {
    await kakao.UserApi.instance.logout();
    prefs.setBool('isLoggedOut', false);
  }*/
  ;
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NavigationExample(),
    );
  }
  /*
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HOOHA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(kaKaoLogin: KakaoLogin()),
    );
  }*/

  /* Future<bool> checkUserInformationExists() async {
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
  }*/
}
