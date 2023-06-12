abstract class SocialLogin { //추상 클래스 정의
  Future<bool> login(); //비동기 네트워크 통신 방법 -> 로그인 , 성공했는지 아닌지는 boolean으로 return
  Future<bool> logout(); //로그아웃
}