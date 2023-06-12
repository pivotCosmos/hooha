import 'package:flutter/material.dart';
import 'package:flutter_application_1/kakao_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/Login_Page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ignore: non_constant_identifier_names
String OPENAI_API_KEY = dotenv.env['OPEN_AI_API_KEY']!;
// ignore: constant_identifier_names
const String MODEL_ID = 'gpt-3.5-turbo';

void main() async {
  await dotenv.load(fileName: 'assets/images/.env');
  WidgetsFlutterBinding.ensureInitialized();
  kakao.KakaoSdk.init(nativeAppKey: dotenv.env['NATIVE_APP_KEY']);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Firebase 초기화

  // 로그아웃 처리
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedOut = prefs.getBool('isLoggedOut') ?? false;
  if (isLoggedOut) {
    await kakao.UserApi.instance.logout();
    prefs.setBool('isLoggedOut', false);
  }

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
      home: LoginPage(kaKaoLogin: KakaoLogin()),
    );
  }
}
