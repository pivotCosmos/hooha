import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/user.dart';
import 'package:flutter_application_1/utils/user_preferences.dart';
import 'package:flutter_application_1/widget/textfield_widget.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  EditProfilePage({required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late User _updatedUser;

  @override
  void initState() {
    super.initState();
    _updatedUser = widget.user;
  }

  // 프로필 수정 창
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        physics: ScrollPhysics(),
        children: [
          const SizedBox(height: 24),
          TextFieldWidget(
            label: '이름',
            text: _updatedUser.name,
            onChanged: (name) =>
                _updatedUser = _updatedUser.copyWith(name: name),
          ),
          const SizedBox(height: 24),
          TextFieldWidget(
            label: '나이',
            text: _updatedUser.age,
            onChanged: (age) => _updatedUser = _updatedUser.copyWith(age: age),
          ),
          const SizedBox(height: 24),
          TextFieldWidget(
            label: '성별',
            text: _updatedUser.gender,
            onChanged: (gender) =>
                _updatedUser = _updatedUser.copyWith(gender: gender),
          ),
          const SizedBox(height: 24),
          TextFieldWidget(
            label: '흡연 기간',
            text: _updatedUser.smoking_year,
            onChanged: (smoking_year) => _updatedUser =
                _updatedUser.copyWith(smoking_year: smoking_year),
          ),
          const SizedBox(height: 24),
          TextFieldWidget(
            label: '금연 시작일',
            text: _updatedUser.end_date,
            onChanged: (end_date) =>
                _updatedUser = _updatedUser.copyWith(end_date: end_date),
          ),
          // 저장 버튼
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              UserPreferences.setUser(_updatedUser);
              Navigator.of(context).pop(_updatedUser);
            },
            child: Text('저장'),
          ),
        ],
      ),
    );
  }
}
