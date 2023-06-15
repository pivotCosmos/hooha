import 'package:flutter/material.dart';
import '/pages/InputInfo_Page.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import '/kakao_login.dart';
import '/main_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  final KakaoLogin kaKaoLogin;

  LoginPage({Key? key, required this.kaKaoLogin}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final viewModel = MainViewModel(KakaoLogin());
  String imagePath = 'assets/images/LoginPagePicture.png'; // 로그인 이전 초기사진

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 9.67),
                    Image.asset(
                      'assets/images/KakaoTalk_20230615_114454909_01.png',
                      width: 300,
                      height: 200,
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () async {
                        await viewModel.login();
                        setState(() {});
                      },
                      child: SizedBox(
                        width: 220,
                        height: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFFEE500),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Image.asset(
                                    'assets/images/KakaoTalk_20230615_114454909.png'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                User? user = snapshot.data;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network(
                      viewModel.user?.kakaoAccount?.profile?.profileImageUrl ??
                          '',
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container();
                      },
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        await viewModel.logout();
                        setState(() {});
                      },
                      child: const Text('로그아웃'),
                    ),
                    const SizedBox(height: 16.0),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InputInfoPage()),
                        );
                      },
                      child: const Text('HOOHA 시작하기'),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
