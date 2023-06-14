import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  DateTime _selectedDate = DateTime.now();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _journalController = TextEditingController();
  List<Map<String, String>> _journalList = [];
  late DocumentReference _userDocRef;

  @override
  void initState() {
    super.initState();
    _fetchJournalList();
  }

  Future<void> _initializeFirestore() async {
    final kakao.User user = await kakao.UserApi.instance.me();
    _userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.id.toString());
  }

  Future<void> _fetchJournalList() async {
    await _initializeFirestore(); // Firestore 초기화
    final snapshot = await _userDocRef.collection('diary').get();
    final List<Map<String, String>> journalList = [];

    snapshot.docs.forEach((doc) {
      final data = doc.data();
      final title = data['제목'] as String?;
      final date = data['날짜'] as String?;
      final journal = data['내용'] as String?;

      if (title != null && date != null && journal != null) {
        journalList.add({
          'title': title,
          'date': date,
          'journal': journal,
        });
      }
    });

    setState(() {
      _journalList = journalList;
    });
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveJournal() async {
    String title = _titleController.text.trim();
    String journalText = _journalController.text.trim();

    if (title.isNotEmpty && journalText.isNotEmpty) {
      final journalDate =
          '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';

      // Firestore에 일지 내용 저장
      await _userDocRef.collection('diary').doc(journalDate).set({
        '제목': title,
        '날짜': journalDate,
        '내용': journalText,
      });

      setState(() {
        _journalList.add({
          'title': title,
          'date': journalDate,
          'journal': journalText,
        });
        _titleController.clear();
        _journalController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white, // 상단바 배경색을 흰색으로 설정
        title: const Text(
          '일지 작성',
          style: TextStyle(color: Colors.black), // 텍스트 색상을 검정색으로 설정
        ),
        iconTheme: IconThemeData(color: Colors.black), // 뒤로가기 아이콘 색상을 검정색으로 설정
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '선택한 날짜: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                  style: const TextStyle(fontSize: 18.0),
                ),
                OutlinedButton(
                  onPressed: _selectDate,
                  child: const Text('날짜 선택'),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _journalController,
                  decoration: const InputDecoration(
                    labelText: '일지 작성',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),
                OutlinedButton(
                  onPressed: _saveJournal,
                  child: const Text('일지 작성'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _journalList.length,
              itemBuilder: (context, index) {
                final journal = _journalList[index];
                return ExpansionTile(
                  title: Text(
                    journal['title'] ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(journal['date'] ?? ''),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(journal['journal'] ?? ''),
                    ),
                  ],
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        _journalList.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.delete),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
