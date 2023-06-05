import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_settings_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  DateTime? _quitDate;

  DateTime dateTime = DateTime.now(); // 사용자가 선택한 시간을 저장

  @override
  void initState() {
    super.initState();
    _loadUserInformation();
  }

  Future<void> _loadUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = sharedPreferences.getString('name') ?? '';
      _selectedGender = sharedPreferences.getString('gender');
      final quitDateMilliseconds = sharedPreferences.getInt('quitDate');
      _quitDate = quitDateMilliseconds != null
          ? DateTime.fromMillisecondsSinceEpoch(quitDateMilliseconds)
          : null;
    });
  }

  Future<void> _saveUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('name', _nameController.text);
    sharedPreferences.setString('gender', _selectedGender ?? '');
    if (_quitDate != null) {
      sharedPreferences.setInt('quitDate', _quitDate!.millisecondsSinceEpoch);
    } else {
      sharedPreferences.remove('quitDate');
    }
  }

  void _updateUserInformation() {
    // Perform the necessary actions to update user information
    // For example, make an API call to update the user information on the server
    // You can access the updated values using _nameController.text, _selectedGender, _quitDate
  } //

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: 'male',
                  child: Text('남성'),
                ),
                DropdownMenuItem(
                  value: 'female',
                  child: Text('여성'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: '성별',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _quitDate ?? DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _quitDate = pickedDate;
                  });
                }
              },
              child: Text(
                _quitDate != null
                    ? '금연 시작일: ${_quitDate!.toString().split(' ')[0]}'
                    : '금연 시작 날짜',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _saveUserInformation();
                _updateUserInformation();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('정보가 저장되었습니다.')),
                );
              },
              child: const Text('저장'),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              leading: Icon(Icons.notifications), // 아이콘 추가
              title: Text('알림 설정'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationSettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
