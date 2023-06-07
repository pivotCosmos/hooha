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
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (!snapshot.hasData || snapshot.data == null) {
                return ElevatedButton(
                  onPressed: () async {
                    await viewModel
                        .login(); // kaKaoLogin 인스턴스의 login 메서드를 호출합니다.
                    setState(() {});
                  },
                  child: const Text('Login'),
                );
              } else {
                User? user = snapshot.data;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network(
                      viewModel.user?.kakaoAccount?.profile?.profileImageUrl ??
                          '',
                      errorBuilder: (context, error, stackTrace) {
                        // 에러 발생 시 빈 컨테이너 반환하여 이미지가 표시되지 않도록 처리
                        return Container();
                      },
                    ),
                    Text(
                      '${viewModel.isLogined}',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await viewModel
                            .logout(); // kaKaoLogin 인스턴스의 logout 메서드를 호출합니다.
                        setState(() {});
                      },
                      child: const Text('Logout'),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InputInfoPage()),
                        );
                      },
                      child: const Text('사용자 정보 입력'),
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
