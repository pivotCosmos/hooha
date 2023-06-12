import 'package:firebase_auth/firebase_auth.dart';
import '/firebase_auth_remote_data_source.dart';
import '/social_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

class MainViewModel {
  //sdk가 잘 동작하는지 검증
  final _firebaseAuthDataSource = FirebaseAuthRemoteDataSource();
  final SocialLogin _socialLogin; //인터페이스 객체
  bool isLogined = false; //처음엔 로그인이 안된 상태로 세팅
  kakao.User? user;

  MainViewModel(this._socialLogin); //생성자에서 세팅해서 객체 가질것

  Future login() async {
    isLogined = await _socialLogin.login(); //로그인 상태를 sociallogin의 결과로 해줌
    if (isLogined) {
      //로그인이 성공했다면
      user = await kakao.UserApi.instance.me(); //현재 로그인된 유저 정보를 가져옴
      //토큰을 얻으려면 유저정보 필요. 유저 정보를 얻은 시점 이후에 토큰발급받기위해 유저정보를 서버에 보낸다.
      final token = await _firebaseAuthDataSource.createCustomToken({
        //createcustomtoken에 내용받아서 customtoken에 보내주기.
        'uid': user!.id.toString(), //user객체의 id를 String으로 변환
        'displayName': user!.kakaoAccount!.profile!.nickname,
        'email': user!.kakaoAccount!.email!,
        'photoURL': user!.kakaoAccount!.profile!.profileImageUrl!,
      });
      await FirebaseAuth.instance.signInWithCustomToken(token);
    }
  }

  Future logout() async {
    await _socialLogin.logout();
    await FirebaseAuth.instance.signOut();
    isLogined = false;
    user = null;
  }
}
