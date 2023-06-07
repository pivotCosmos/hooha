import 'package:flutter/material.dart';

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

  void _saveJournal() {
    String title = _titleController.text.trim();
    String journalText = _journalController.text.trim();
    if (title.isNotEmpty && journalText.isNotEmpty) {
      setState(() {
        _journalList.add({
          'title': title,
          'date': '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
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
      appBar: AppBar(
        title: const Text('일지 작성'),
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
                ElevatedButton(
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
                ElevatedButton(
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
