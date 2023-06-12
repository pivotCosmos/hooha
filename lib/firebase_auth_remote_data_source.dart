import 'package:http/http.dart' as http;

class FirebaseAuthRemoteDataSource {
    final String url = 'https://us-central1-hooha-app.cloudfunctions.net/createCustomToken'; //서버 구축했을때 url
    //토큰발급 받기위해선 post요청해야됨.
    Future<String> createCustomToken(Map<String,dynamic> user) async { 
        final customTokenResponse = await http
        .post(Uri.parse(url), body: user); 
        //토큰을 얻었을때 body로 토큰을 보내서 얻기
        return customTokenResponse.body;
    }
}