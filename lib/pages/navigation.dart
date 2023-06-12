import 'package:flutter/material.dart';
import '/pages/GPS_page.dart';
import '/pages/Home_page.dart';
import '/pages/Calendar_Page.dart';
import '/pages/CounselPage.dart';
import '/pages/MyPage.dart';

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
          elevation: 0, //그림자 없애기
        backgroundColor: Colors.white,
        title: const Text(
          "HOOHA",
          style: TextStyle(
            color: Color(0xff374151),
            fontSize: 24,
            fontFamily: "Inter",
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: null,
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
          NavigationDestination(
            icon: Icon(Icons.compass_calibration),
            label: 'GPS',
          ),
        ],
      ),
      body: _buildPage(currentPageIndex),
    );
  }

  Widget _buildPage(int index) {
    if (index == 0) {
      return const MainPage();
    } else if (index == 1) {
      return const CalendarPage();
    } else if (index == 2) {
      return const GetCounsel();
    } else if (index == 3) {
      return const MyPage();
    } else if (index == 4) {
      return MapSample();
    } else {
      return Container();
    }
  }
}
