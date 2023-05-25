import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/pages/navigation.dart';

enum Gender { male, female }

class InputInfoPage extends StatefulWidget {
  final VoidCallback? onInfoEntered;

  const InputInfoPage({Key? key, this.onInfoEntered}) : super(key: key);

  @override
  _InputInfoPageState createState() => _InputInfoPageState();
}

class _InputInfoPageState extends State<InputInfoPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  Gender? _selectedGender;
  DateTime? _selectedDate;

  Future<void> _saveUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('name', _nameController.text);
    sharedPreferences.setString('gender', _selectedGender.toString().split('.').last);
    if (_selectedDate != null) {
      sharedPreferences.setInt('quitDate', _selectedDate!.millisecondsSinceEpoch);
    }
    
    if (widget.onInfoEntered != null) {
      widget.onInfoEntered!(); // onInfoEntered 콜백 호출
    }
  }

  void _navigateToMainPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationExample(),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 정보 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해 주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
               Text(
                _selectedGender == Gender.male ? '성별: 남성' : '성별: 여성',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Row(
                children: [
                  Radio<Gender>(
                    value: Gender.male,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const Text('남성'),
                  Radio<Gender>(
                    value: Gender.female,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const Text('여성'),
                ],
              ),
            
              ElevatedButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  _selectedDate != null ? '시작 날짜: ${_selectedDate!.toString().split(' ')[0]}' : '금연 시작 날짜',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() == true &&
                      _selectedGender != null &&
                      _selectedDate != null) {
                    _saveUserInformation();
                    _navigateToMainPage();
                  }
                },
                child: const Text('입력'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
