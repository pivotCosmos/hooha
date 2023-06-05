import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
// 버튼 클릭 시 Firestore 카운트 업데이트

void updateCount(String fieldId) {
  FirebaseFirestore.instance
      .collection('feedback')
      .doc('negative')
      .update({fieldId: FieldValue.increment(1)})
      .then((_) => print('카운트 업데이트 성공'))
      .catchError((error) => print('카운트 업데이트 실패: $error'));
}

void updatecount(String fieldId) {
  FirebaseFirestore.instance
      .collection('feedback')
      .doc('positive')
      .update({fieldId: FieldValue.increment(1)})
      .then((_) => print('카운트 업데이트 성공'))
      .catchError((error) => print('카운트 업데이트 실패: $error'));
}

void showDialogFunction(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('피드백을 부탁드립니다'),
        content: Text('어떤 점이 불편하셨나요? 고객님의 소중한 의견 부탁드립니다.'),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                updateCount('Harmful'); // 버튼 1 카운트 업데이트
                Navigator.of(context).pop(); // Dialog 닫기
              },
              child: Text(
                '해로움',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                updateCount('Not_True'); // 버튼 2 카운트 업데이트
                Navigator.of(context).pop(); // Dialog 닫기
              },
              child: Text(
                '사실이 아님',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                updateCount(
                  'Not_helpful',
                ); // 버튼 3 카운트 업데이트
                Navigator.of(context).pop(); // Dialog 닫기
              },
              child: Text(
                '도움이 안됨',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                updateCount('Slow_answer'); // 버튼 4 카운트 업데이트
                Navigator.of(context).pop(); // Dialog 닫기
              },
              child: Text(
                '답변이 느림',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
        ],
      );
    },
  );
}
