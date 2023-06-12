import '/social_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLogin implements SocialLogin {
  @override
  Future<bool> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      if (isInstalled) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
          return true;
        } catch (e) {
          print('카카오톡으로 로그인 실패 $e');
          return false;
        }
      } else {
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          return true;
        } catch (e) {
          print('카카오계정 로그인에러발생 $e');
          print(await KakaoSdk.origin);
          return false;
        }
      }
    } catch (e) {
      print('카톡/계정 에러 둘다아님');
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await UserApi.instance.unlink();
      return true;
    } catch (error) {
      return false;
    }
  }
}
