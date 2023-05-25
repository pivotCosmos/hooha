import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/user.dart';
import 'package:flutter_application_1/utils/user_preferences.dart';
import 'package:flutter_application_1/pages/EditProfilePage.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  User user = UserPreferences.getUser();
  //LIstView.builder를 이용해 리스트 작성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: 5, // 사용자 정보의 항목 수에 따라 조정
          itemBuilder: (BuildContext context, int index) {
            String title;
            String value;

            switch (index) {
              case 0:
                title = '이름';
                value = user.name;
                break;
              case 1:
                title = '나이';
                value = user.age;
                break;
              case 2:
                title = '성별';
                value = user.gender;
                break;
              case 3:
                title = '흡연 기간';
                value = user.smoking_year;
                break;
              case 4:
                title = '흡연 시작일';
                value = user.end_date;
                break;
              default:
                title = '';
                value = '';
                break;
            }

            return Card(
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 60,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        height: 3.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(children: [Text(value)]),
                  )
                ],
              ),
            );
          },
        ),
      ),
      //편집 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedUser = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditProfilePage(user: user)),
          );

          if (updatedUser != null) {
            setState(() {
              user = updatedUser;
            });
          }
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}
