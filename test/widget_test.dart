import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 앱 실행
  runApp(MyApp());

  // Firebase 앱 초기화
  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  // Firestore 인스턴스 가져오기
  FirebaseFirestore db = FirebaseFirestore.instance;

  // 나머지 코드 작성
  final user = <String, dynamic>{
    "first": "Ada",
    "last": "Lovelace",
    "born": 1815
  };
  print(user);

  // Firestore에 문서 추가
  db.collection("users").add(user).then((DocumentReference doc) =>
      print('DocumentSnapshot added with ID: ${doc.id}'));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
      ),
      body: Center(
        child: Text('Hello, World!'),
      ),
    );
  }
}
