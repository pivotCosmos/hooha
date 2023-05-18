import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final List<String> notifications; // 알림 리스트를 저장하기 위한 변수로, 해당 페이지로 전달됨.

  const NotificationPage({Key? key, required this.notifications}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'), //알림 페이지의 상단바에 표시될 타이틀
      ),
      body: ListView.builder(
        itemCount: notifications.length,// 알림 리스트의 아이템 개수: 알림 리스트의 아이템 개수를 나타내며, ListView.builder 위젯에서 사용됨.
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notifications[index]), // 알림 아이템 텍스트: 알림 리스트의 각 아이템을 표시하기 위한 ListTile 위젯의 타이틀.
                                               // notifications 리스트에서 각 아이템을 가져와 텍스트로 표시
          );
        },
      ),
    );
  }
}
