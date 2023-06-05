// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _attendanceCount = 0;
  int _consecutiveDays = 0;
  bool _isAttendanceCompleted = false;
  // ignore: unused_field
  DateTime _currentDate = DateTime.now();

  final EventList<Event> _markedDateMap = EventList<Event>(events: {});

  @override
  void initState() {
    super.initState();
    _loadAttendanceCount();
  }

  Future<void> _loadAttendanceCount() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _attendanceCount = sharedPreferences.getInt('attendanceCount') ?? 0;
      _consecutiveDays = sharedPreferences.getInt('consecutiveDays') ?? 0;
      _isAttendanceCompleted =
          sharedPreferences.getBool('isAttendanceCompleted') ?? false;
    });
  }

  Future<void> _checkAttendance() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final lastAttendanceDateStr =
        sharedPreferences.getString('lastAttendanceDate');
    if (lastAttendanceDateStr != null) {
      final lastAttendanceDate = DateTime.parse(lastAttendanceDateStr);
      final difference = now.difference(lastAttendanceDate).inDays;
      if (difference < 1) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('알림'),
            content: const Text('이미 오늘 출석체크를 하였습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
        return;
      }
    }

    // 출석 체크
    setState(() {
      _attendanceCount++;
      _consecutiveDays++;
      _isAttendanceCompleted = true;
    });
    // 오늘 출석체크한 날짜를 저장
    sharedPreferences.setString('lastAttendanceDate', now.toString());
    // 출석체크한 날짜를 _markedDateMap에 추가
    _markedDateMap.add(
      now,
      Event(
        date: now,
        dot: Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );

    // 출석체크 관련 정보 저장
    sharedPreferences.setInt('attendanceCount', _attendanceCount);
    sharedPreferences.setInt('consecutiveDays', _consecutiveDays);
    sharedPreferences.setBool('isAttendanceCompleted', _isAttendanceCompleted);
    sharedPreferences.setString('lastAttendanceDate', now.toString());

    // 알림 표시
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('알림'),
        content: const Text('출석체크 되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );

    // 화면 다시 그리기
    setState(() {});
  }

  Future<void> _resetAttendance() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _attendanceCount = 0;
      _consecutiveDays = 0;
      _isAttendanceCompleted = false;
      _markedDateMap.clear();
    });

    sharedPreferences.remove('attendanceCount');
    sharedPreferences.remove('consecutiveDays');
    sharedPreferences.remove('isAttendanceCompleted');
    sharedPreferences.remove('lastAttendanceDate');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('알림'),
        content: const Text('출석체크 기록이 초기화되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('출석체크'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '출석 일수: $_attendanceCount일',
                style: const TextStyle(fontSize: 18.0),
              ),
              Text(
                '연속 출석일: $_consecutiveDays일',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _checkAttendance,
                child: const Text('출석체크'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _resetAttendance, // 수정: 출석체크 기록 초기화 버튼
                child: const Text('출석체크 기록 초기화'),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CalendarCarousel<Event>(
                  onDayPressed: (DateTime date, List<Event> events) {
                    setState(() => _currentDate = date);
                  },
                  weekendTextStyle: const TextStyle(
                    color: Color.fromARGB(255, 36, 128, 205),
                  ),
                  thisMonthDayBorderColor: Colors.grey,
                  markedDatesMap: _markedDateMap,
                  customDayBuilder: (
                    bool isSelectable,
                    int index,
                    bool isSelectedDay,
                    bool isToday,
                    bool isPrevMonthDay,
                    TextStyle textStyle,
                    bool isNextMonthDay,
                    bool isThisMonthDay,
                    DateTime day,
                  ) {
                    final eventList = _markedDateMap.events[day];
                    if (eventList != null && eventList.isNotEmpty) {
                      return Container(
                        margin: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: Center(
                          child: Text(
                            day.day.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return null;
                    }
                  },
                  weekFormat: false,
                  height: 360.0,
                  daysHaveCircularBorder: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
