import 'package:flutter/material.dart';
import '/pages/Home_page.dart';
import '/pages/Calendar_Page.dart';
import '/pages/counsel_page.dart';
import '/pages/MyPage.dart';
import '/pages/Notification_page.dart';

class NavigationExample extends StatefulWidget {
  const NavigationExample({Key? key}) : super(key: key);

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  List<String> notifications = []; //알림 리스트
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationPage(notifications: notifications),
                  ),
                );
              },
              color: Colors.black, // 알림 아이콘의 색상을 검은색으로 설정
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "HOOHA",
                      style: TextStyle(
                        color: Color(0xff374151),
                        fontSize: 24,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      body: _buildPage(currentPageIndex), // 수정된 부분
    );
  }

  Widget _buildPage(int index) {
    if (index == 0) {
      return const MainPage(); // 사용자 정보가 표시될 페이지
    } else if (index == 1) {
      return const CalendarPage();
    } else if (index == 2) {
      return const GetCounsel();
    } else if (index == 3) {
      return const MyPage();
    } else {
      return Container();
    }
  }
}
