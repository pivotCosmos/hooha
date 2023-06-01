import 'package:flutter/material.dart';
import './home_page.dart';
import './calendar_page.dart';
import './counsel_page.dart';
import './my_page.dart';
import './notification_page.dart';

class NavigationExample extends StatefulWidget {
  const NavigationExample({Key? key}) : super(key: key);

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  List<String> notifications = []; //알림 리스트
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'HOOHA',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              //알림 아이콘 눌렀을 때 실행될 로직 추가(예정)
              Navigator.push(
                  // 새로운 페이지로 이동하는 메서드 (NotificationPage로 이동)
                  context,
                  MaterialPageRoute(
                      //새로운 페이지를 생성
                      //builder 함수를 통해 NotificationPage 인스턴스를 생성
                      builder: (context) => NotificationPage(
                          notifications:
                              notifications))); //notifications 변수를 페이지로 전달
            },
          )
        ], //actions
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_sharp),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            label: 'Counsel',
          ),
          NavigationDestination(
            icon: Icon(Icons.supervised_user_circle_sharp),
            label: 'MyPage',
          ),
        ],
      ),
      body: <Widget>[
        const HomePage(),
        const CalendarPage(),
        const GetCounsel(),
        const MyPage(),
      ][currentPageIndex],
    );
  }
}
