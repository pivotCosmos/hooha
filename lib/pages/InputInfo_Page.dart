import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/pages/navigation.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

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
  String? _selectedJob;

  @override
  void initState() {
    super.initState();
    _checkUserInformation();
  }

  Future<void> _checkUserInformation() async {
    final kakao.User user = await kakao.UserApi.instance.me();
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.id.toString());

    final userFromFirestore = await userDocRef.get();
    if (userFromFirestore.exists) {
      // 사용자 정보가 이미 있으면 InputInfoPage를 건너뛰고 다음 페이지로 이동
      _navigateToMainPage();
    }
  }

  Future<void> _saveUserInformation() async {
    if (_selectedJob == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('경고'),
            content: Text('직업을 선택해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    final kakao.User user = await kakao.UserApi.instance.me();
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.id.toString());

    final userFromFirestore = await userDocRef.get();
    if (!userFromFirestore.exists) {
      await userDocRef.set({
        'userId': user.id.toString(),
        'displayName': user.kakaoAccount?.profile?.nickname,
        'email': user.kakaoAccount?.email,
        'name': _nameController.text,
        'gender': _selectedGender == Gender.male ? 'male' : 'female',
        'quitDate': _selectedDate != null
            ? _selectedDate!.millisecondsSinceEpoch
            : null,
        'job': _selectedJob,
      });
    }
    if (widget.onInfoEntered != null) {
      widget.onInfoEntered!(); // onInfoEntered 콜백 호출
    }

    _navigateToMainPage();
  }

  void _navigateToMainPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationExample(), // 다음 페이지로 이동
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
        backgroundColor: Colors.white, // 흰색 배경색
        title: const Center(
          child: Text(
            'HOOHA',
            style: TextStyle(
              color: Color(0xff374151), // 검은색 글자색
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final selectedJob = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      String? job;
                      return AlertDialog(
                        title: Text('직업 선택'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<String>(
                              title: const Text('직장인'),
                              value: '직장인',
                              groupValue: job,
                              onChanged: (value) {
                                job = value;
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('학생'),
                              value: '학생',
                              groupValue: job,
                              onChanged: (value) {
                                job = value;
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('주부'),
                              value: '주부',
                              groupValue: job,
                              onChanged: (value) {
                                job = value;
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('군인'),
                              value: '군인',
                              groupValue: job,
                              onChanged: (value) {
                                job = value;
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('무직'),
                              value: '무직',
                              groupValue: job,
                              onChanged: (value) {
                                job = value;
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, null);
                            },
                            child: Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, job);
                            },
                            child: Text('확인'),
                          ),
                        ],
                      );
                    },
                  );

                  setState(() {
                    _selectedJob = selectedJob;
                  });
                },
                child: Text(
                  _selectedJob != null ? '직업: $_selectedJob' : '직업 선택',
                ),
              ),
              const SizedBox(height: 16.0),
              TextButton(
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
                  _selectedDate != null
                      ? '금연 시작일: ${_selectedDate!.toString().split(' ')[0]}'
                      : '금연 시작 날짜:',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() == true &&
                      _selectedGender != null &&
                      _selectedDate != null &&
                      _selectedJob != null) {
                    _saveUserInformation();
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
